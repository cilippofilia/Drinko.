//
//  CloudSync.swift
//  DrinkoPro
//

import Foundation
import OSLog

/// Mirrors favorites, recents and settings between `UserDefaults` and iCloud's key-value store,
/// so they match across the user's devices and come back after reinstalling.
///
/// `UserDefaults` stays the place the app reads from. Local changes to the keys in
/// `CloudSyncedKey.all` are uploaded; changes from other devices are written back into
/// `UserDefaults`, where `@AppStorage` views pick them up, and `onRemoteChange` lets the stores
/// reload. A device's first sync merges local and iCloud values (see `CloudSyncMerge`); after
/// that the latest change wins. Signed out of iCloud, uploads go nowhere and nothing arrives.
@MainActor
final class CloudSync {
    /// Local-only flag recording that this device has merged with iCloud. Never synced.
    static let didInitialMergeKey = "cloudSync.didInitialMerge"

    private let cloud: CloudKeyValueStore
    private let standard: UserDefaults
    private let appGroup: UserDefaults
    private let keys: [CloudSyncedKey]
    private let onRemoteChange: (Set<String>) -> Void
    private let logger = Logger(subsystem: "me.cilia.filippo.DrinkoPro", category: "CloudSync")

    /// The last local value seen for each key, so a change notification only uploads what
    /// changed, and values written from iCloud aren't sent back.
    private var snapshot: [String: Any] = [:]

    // Only mutated in `start()` on the main actor; read in `deinit` to remove the observers.
    nonisolated(unsafe) private var observers: [NSObjectProtocol] = []

    /// - Parameter onRemoteChange: Called with the names of the keys written locally from iCloud.
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

        for key in keys {
            snapshot[key.name] = defaults(for: key).object(forKey: key.name)
        }
        observeLocalChanges()
        observeCloudChanges()

        cloud.synchronize()
        if standard.bool(forKey: Self.didInitialMergeKey) {
            pull(keys)
        } else {
            mergeAll()
        }
    }

    /// Applies a change notification from iCloud.
    func handleCloudChange(reason: Int, changedKeys: [String]) {
        switch reason {
        case NSUbiquitousKeyValueStoreAccountChange:
            // A different iCloud account: combine its data with this device's, like a new device.
            standard.removeObject(forKey: Self.didInitialMergeKey)
            mergeAll()
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            // iCloud discards writes made before a device's first download, so the launch merge
            // may never have reached it. Merge again with what arrived.
            mergeAll()
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            logger.error("iCloud key-value storage is over its quota")
        default:
            if standard.bool(forKey: Self.didInitialMergeKey) {
                pull(keys.filter { changedKeys.contains($0.name) })
            } else {
                mergeAll()
            }
        }
    }

    /// Uploads synced values that changed locally since they were last seen.
    func pushLocalChanges() {
        for key in keys {
            let value = defaults(for: key).object(forKey: key.name)
            guard !Self.isEqual(value, snapshot[key.name]) else { continue }
            snapshot[key.name] = value
            // Removed values aren't removed from iCloud, so a reset can't wipe other devices.
            if let value {
                cloud.set(value, forKey: key.name)
            }
        }
    }

    // MARK: - Syncing

    /// Combines local and iCloud values by each key's rule and writes the result to both.
    private func mergeAll() {
        var changed: Set<String> = []
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

            if !Self.isEqual(merged, local) {
                // Snapshot first, so the change notification doesn't upload it again.
                snapshot[key.name] = merged
                defaults.set(merged, forKey: key.name)
                changed.insert(key.name)
            }
            if !Self.isEqual(merged, remote) {
                cloud.set(merged, forKey: key.name)
            }
        }
        standard.set(true, forKey: Self.didInitialMergeKey)
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
            object: nil,
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
