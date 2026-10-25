//
//  CloudSync.swift
//  DrinkoPro
//

import Foundation
import OSLog

/// Mirrors favorites, recents and settings between `UserDefaults` and iCloud's key-value store.
///
/// The app keeps reading `UserDefaults`. Changes from other devices are written back into it,
/// where `@AppStorage` views pick them up, and `onRemoteChange` lets the stores reload. A
/// device's first sync merges local and iCloud values (see `CloudSyncMerge`); after that the
/// latest change wins.
@MainActor
final class CloudSync {
    /// Local-only flag recording that this device has merged with iCloud. Never synced.
    static let didInitialMergeKey = "cloudSync.didInitialMerge"

    /// Local-only flag recording that a launch found iCloud empty and waited for its first
    /// download. If iCloud is still empty on a later launch, this device is the first one.
    static let awaitingFirstDownloadKey = "cloudSync.awaitingFirstDownload"

    /// Local-only copy of `snapshot`, so a launch can tell which values another process (the
    /// widget) changed while the app was closed. Never synced. A property-list dictionary:
    /// `keys` names the keys it covers, and `values` holds their non-nil values.
    static let lastSyncedKey = "cloudSync.lastSynced"
    private static let lastSyncedKeysField = "keys"
    private static let lastSyncedValuesField = "values"

    private let cloud: CloudKeyValueStore
    private let standard: UserDefaults
    private let appGroup: UserDefaults
    private let keys: [CloudSyncedKey]
    private let onRemoteChange: (Set<String>) -> Void
    private let logger = Logger(subsystem: "me.cilia.filippo.DrinkoPro", category: "CloudSync")

    /// The last local value seen for each key, so a change notification only uploads what
    /// changed, and values written from iCloud aren't sent back.
    /// Persisted under `lastSyncedKey` at the end of each operation that changes it.
    private var snapshot: [String: Any] = [:]

    /// Keys uploaded since the app last became active. A push triggered by any in-process write
    /// can upload a widget change before the app is active, so `appDidBecomeActive` reports
    /// these too, and the stores reload what the widget wrote.
    private var pushedSinceActive: Set<String> = []

    // Only mutated in `start()` on the main actor; read in `deinit` to remove the observers.
    nonisolated(unsafe) private var observers: [NSObjectProtocol] = []

    /// - Parameter onRemoteChange: Called with the names of the keys written locally from iCloud,
    ///   and, from `appDidBecomeActive()`, of the keys uploaded since the app was last active, so
    ///   the stores reload values another process wrote.
    init(
        cloud: CloudKeyValueStore = NSUbiquitousKeyValueStore.default,
        standard: UserDefaults = .standard,
        appGroup: UserDefaults = AppGroup.defaults,
        keys: [CloudSyncedKey] = CloudSyncedKey.all,
        onRemoteChange: @escaping (Set<String>) -> Void
    ) {
        self.cloud = cloud
        self.standard = standard
        self.appGroup = appGroup
        self.keys = keys
        self.onRemoteChange = onRemoteChange
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// Starts mirroring. Call once, after local migrations have run.
    func start() {
        guard observers.isEmpty else { return }

        let didInitialMerge = standard.bool(forKey: Self.didInitialMergeKey)
        // On a merged device, start from what was last synced, so values changed in another
        // process since then are uploaded below instead of overwritten by iCloud's older ones.
        // Keys the saved copy doesn't cover start from their local value, so iCloud's wins.
        let lastSynced = didInitialMerge ? loadLastSynced() : nil
        for key in keys {
            if let lastSynced, lastSynced.keys.contains(key.name) {
                snapshot[key.name] = lastSynced.values[key.name]
            } else {
                snapshot[key.name] = defaults(for: key).object(forKey: key.name)
            }
        }
        observeLocalChanges()
        observeCloudChanges()

        cloud.synchronize()
        if didInitialMerge {
            // Local changes made while closed win over iCloud: latest change wins.
            pushLocalChanges()
            pull(keys)
            // Saved even when nothing changed, so a device that has never saved one has a
            // copy to compare against on its next launch.
            persistSnapshot()
        } else {
            // Wait for iCloud's first download unless an earlier launch already waited.
            mergeAll(evenIfCloudIsEmpty: standard.bool(forKey: Self.awaitingFirstDownloadKey))
        }
    }

    func handleCloudChange(reason: Int, changedKeys: [String]) {
        switch reason {
        case NSUbiquitousKeyValueStoreAccountChange:
            // A different iCloud account: combine its data with this device's, like a new device.
            standard.removeObject(forKey: Self.didInitialMergeKey)
            standard.removeObject(forKey: Self.awaitingFirstDownloadKey)
            mergeAll(evenIfCloudIsEmpty: false)
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            // iCloud discards writes made before a device's first download, so the launch merge
            // may never have reached it. Merge again with what arrived. The download happened,
            // so an empty iCloud really is empty.
            mergeAll(evenIfCloudIsEmpty: true)
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            logger.error("iCloud key-value storage is over its quota")
        default:
            if standard.bool(forKey: Self.didInitialMergeKey) {
                // Upload values another process changed first, as `start()` does, so a pull
                // while resuming can't overwrite them before `appDidBecomeActive` runs.
                pushLocalChanges()
                pull(keys.filter { changedKeys.contains($0.name) })
            } else {
                // iCloud just delivered data, so this is the first download.
                mergeAll(evenIfCloudIsEmpty: true)
            }
        }
    }

    /// Uploads synced values that changed locally since they were last seen. Does nothing until
    /// this device has merged with iCloud, so an unmerged value can't replace another device's.
    func pushLocalChanges() {
        guard standard.bool(forKey: Self.didInitialMergeKey) else { return }
        var snapshotChanged = false
        var uploaded = false
        for key in keys {
            let value = defaults(for: key).object(forKey: key.name)
            guard !Self.isEqual(value, snapshot[key.name]) else { continue }
            snapshot[key.name] = value
            snapshotChanged = true
            // Removed values aren't removed from iCloud, so a reset can't wipe other devices.
            if let value {
                cloud.set(value, forKey: key.name)
                pushedSinceActive.insert(key.name)
                uploaded = true
            }
        }
        if uploaded {
            cloud.synchronize()
        }
        if snapshotChanged {
            // Re-enters this method through the change notification; the snapshot already
            // matches, so that call does nothing.
            persistSnapshot()
        }
    }

    /// Uploads values another process (the widget) changed while the app was in the
    /// background, where no change notification reaches it, and reloads the stores.
    func appDidBecomeActive() {
        pushLocalChanges()
        let pushed = pushedSinceActive
        pushedSinceActive.removeAll()
        if !pushed.isEmpty {
            onRemoteChange(pushed)
        }
    }

    // MARK: - Syncing

    /// Combines local and iCloud values by each key's rule and writes the result to both.
    /// While iCloud has no valid value for any key and `evenIfCloudIsEmpty` is false, it only
    /// records that it is waiting: iCloud's first download may not have arrived yet.
    private func mergeAll(evenIfCloudIsEmpty: Bool) {
        let cloudHasData = keys.contains { key in
            cloud.object(forKey: key.name).map { CloudSyncMerge.isValid($0, for: key.rule) } ?? false
        }
        guard cloudHasData || evenIfCloudIsEmpty else {
            standard.set(true, forKey: Self.awaitingFirstDownloadKey)
            return
        }

        var changed: Set<String> = []
        var uploaded = false
        for key in keys {
            let defaults = defaults(for: key)
            let local = defaults.object(forKey: key.name)
            let remote = cloud.object(forKey: key.name)
            guard let merged = CloudSyncMerge.firstSync(
                local: local,
                cloud: remote,
                rule: key.rule,
                recentsCapacity: RecentsStore.capacity
            ) else { continue }

            // Snapshot first, so the change notification doesn't upload it again, and so values
            // changed locally while waiting aren't uploaded again by the next notification.
            snapshot[key.name] = merged
            if !Self.isEqual(merged, local) {
                defaults.set(merged, forKey: key.name)
                changed.insert(key.name)
            }
            if !Self.isEqual(merged, remote) {
                cloud.set(merged, forKey: key.name)
                uploaded = true
            }
        }
        if uploaded {
            cloud.synchronize()
        }
        standard.set(true, forKey: Self.didInitialMergeKey)
        standard.removeObject(forKey: Self.awaitingFirstDownloadKey)
        persistSnapshot()
        if !changed.isEmpty {
            onRemoteChange(changed)
        }
    }

    /// Writes iCloud's values for `keysToPull` locally, skipping missing and invalid ones.
    private func pull(_ keysToPull: [CloudSyncedKey]) {
        var changed: Set<String> = []
        for key in keysToPull {
            guard let value = cloud.object(forKey: key.name) else { continue }
            guard CloudSyncMerge.isValid(value, for: key.rule) else {
                logger.error("Skipping an invalid iCloud value for \(key.name, privacy: .public)")
                continue
            }
            let defaults = defaults(for: key)
            guard !Self.isEqual(value, defaults.object(forKey: key.name)) else { continue }

            // Snapshot first, so the change notification doesn't upload it again.
            snapshot[key.name] = value
            defaults.set(value, forKey: key.name)
            changed.insert(key.name)
        }
        if !changed.isEmpty {
            persistSnapshot()
            onRemoteChange(changed)
        }
    }

    // MARK: - Observing

    private func observeLocalChanges() {
        // Posted synchronously on the thread that changed any defaults in this process, for any
        // key, so `pushLocalChanges` diffs the synced keys against the snapshot.
        let observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            if Thread.isMainThread {
                MainActor.assumeIsolated { self.pushLocalChanges() }
            } else {
                Task { @MainActor in self.pushLocalChanges() }
            }
        }
        observers.append(observer)
    }

    private func observeCloudChanges() {
        let observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloud,
            queue: nil
        ) { [weak self] notification in
            guard let self else { return }
            let userInfo = notification.userInfo
            let reason = userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
                ?? NSUbiquitousKeyValueStoreServerChange
            let changedKeys = userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
            Task { @MainActor in
                self.handleCloudChange(reason: reason, changedKeys: changedKeys)
            }
        }
        observers.append(observer)
    }

    // MARK: - Helpers

    /// Saves `snapshot` locally under `lastSyncedKey`, with the keys it covers, so a covered key
    /// with no value reads back as `nil`. Writing posts a change notification that re-enters
    /// `pushLocalChanges`.
    private func persistSnapshot() {
        let lastSynced: [String: Any] = [
            Self.lastSyncedKeysField: keys.map(\.name),
            Self.lastSyncedValuesField: snapshot
        ]
        standard.set(lastSynced, forKey: Self.lastSyncedKey)
    }

    /// Reads what `persistSnapshot()` saved, or `nil` if there is none or it can't be read.
    private func loadLastSynced() -> (keys: Set<String>, values: [String: Any])? {
        guard
            let lastSynced = standard.dictionary(forKey: Self.lastSyncedKey),
            let names = lastSynced[Self.lastSyncedKeysField] as? [String],
            let values = lastSynced[Self.lastSyncedValuesField] as? [String: Any]
        else { return nil }
        return (Set(names), values)
    }

    private func defaults(for key: CloudSyncedKey) -> UserDefaults {
        switch key.suite {
        case .appGroup: appGroup
        case .standard: standard
        }
    }

    /// Compares property-list values (`Data`, `String`, `[String]`, `Bool`) by value.
    private static func isEqual(_ lhs: Any?, _ rhs: Any?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): true
        case let (lhs?, rhs?): (lhs as AnyObject).isEqual(rhs)
        default: false
        }
    }
}
