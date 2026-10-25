import Foundation
import Testing
@testable import DrinkoPro

/// `CloudSync` with values another process (the widget) changed, where this process gets no
/// change notification.
extension CloudSyncTests {
    // MARK: Changes made outside the app

    /// Writes an App Group value the way another process (the widget) would: without posting
    /// `UserDefaults.didChangeNotification` in this process.
    private func writeFromAnotherProcess(_ value: Any, forKey key: String, in harness: Harness) {
        CFPreferencesSetAppValue(key as CFString, value as CFPropertyList, harness.suiteNames[1] as CFString)
    }

    /// Runs a merged sync once with `favorites`, then releases it, like a launch that ends.
    private func runOnce(_ harness: Harness, favorites: Set<String>) throws {
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(favorites), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(favorites)
        let sync = makeSync(harness)
        sync.start()
    }

    @Test func widgetChangeWhileClosedIsUploadedOnLaunch() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        try runOnce(harness, favorites: ["zombie"])
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.writes.removeAll()

        let sync = makeSync(harness)
        sync.start()

        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])
        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni"])
        #expect(harness.cloud.writes == [favoritesKey])
    }

    @Test func remoteChangeStillWinsWhenLocalUntouched() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        try runOnce(harness, favorites: ["zombie"])
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])
        harness.cloud.writes.removeAll()
        let log = ChangeLog()

        let sync = makeSync(harness, log: log)
        sync.start()

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["daiquiri"])
        #expect(harness.cloud.writes.isEmpty)
        #expect(log.changes == [[favoritesKey]])
    }

    @Test func becomingActivePushesOutOfProcessWrite() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["zombie"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["zombie"])
        let log = ChangeLog()
        let sync = makeSync(harness, log: log)
        sync.start()

        writeFromAnotherProcess(try encoded(["negroni"]), forKey: favoritesKey, in: harness)
        // Nothing in this process noticed the write.
        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["zombie"])

        sync.appDidBecomeActive()

        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])
        #expect(log.changes.last?.contains(favoritesKey) == true)
    }

    @Test func becomingActiveReloadsAWidgetChangeAnotherWriteAlreadyUploaded() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["zombie"]), forKey: favoritesKey)
        let log = ChangeLog()
        let sync = makeSync(harness, log: log)
        sync.start()

        writeFromAnotherProcess(try encoded(["negroni"]), forKey: favoritesKey, in: harness)
        // An unrelated in-process write pushes the widget's change before the app is active.
        harness.standard.set("whatever", forKey: "someUnsyncedKey")
        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])

        sync.appDidBecomeActive()

        #expect(log.changes.last?.contains(favoritesKey) == true)
    }

    @Test func lastSyncedStaysLocal() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[layoutKey] = "grid"

        let sync = makeSync(harness)
        sync.start()
        harness.standard.set("list", forKey: otherLayoutKey)
        sync.appDidBecomeActive()

        #expect(harness.standard.object(forKey: CloudSync.lastSyncedKey) != nil)
        #expect(harness.cloud.values[CloudSync.lastSyncedKey] == nil)
        #expect(!harness.cloud.writes.contains(CloudSync.lastSyncedKey))
        #expect(!CloudSyncedKey.all.map(\.name).contains(CloudSync.lastSyncedKey))
    }

    @Test func unreadableLastSyncedFallsBackToLocalValues() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.standard.set("junk", forKey: CloudSync.lastSyncedKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        let sync = makeSync(harness)
        sync.start()

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["daiquiri"])
    }

    @Test func upgradeLaunchWithoutLastSyncedPushesNothing() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.cloud.writes.isEmpty)
        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["daiquiri"])
    }

    @Test func widgetWriteToAKeyThatWasEmptyIsUploaded() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        do {
            // A user with no favorites: the snapshot covers the key with no value.
            let sync = makeSync(harness)
            sync.start()
        }
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)

        let sync = makeSync(harness)
        sync.start()

        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])
    }

    @Test func keyMissingFromLastSyncedLetsICloudWin() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        // Saved by a version that didn't sync favorites yet.
        let lastSynced: [String: Any] = ["keys": [layoutKey], "values": [layoutKey: "list"]]
        harness.standard.set(lastSynced, forKey: CloudSync.lastSyncedKey)
        harness.standard.set("list", forKey: layoutKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.cloud.writes.isEmpty)
        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["daiquiri"])
    }

    @Test func oldFormatLastSyncedFallsBackToLocalValues() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.standard.set([favoritesKey: try encoded(["zombie"])], forKey: CloudSync.lastSyncedKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.cloud.writes.isEmpty)
        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["daiquiri"])
    }

    @Test func remoteChangeWhileResumingKeepsAWidgetWrite() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["zombie"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["zombie"])
        let sync = makeSync(harness)
        sync.start()
        writeFromAnotherProcess(try encoded(["negroni"]), forKey: favoritesKey, in: harness)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreServerChange, changedKeys: [favoritesKey])

        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])
        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni"])
    }

    @Test func remoteChangeReportsAWidgetWriteItUploaded() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["zombie"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["zombie"])
        let log = ChangeLog()
        let sync = makeSync(harness, log: log)
        sync.start()
        log.changes.removeAll()
        writeFromAnotherProcess(try encoded(["negroni"]), forKey: favoritesKey, in: harness)

        // An unrelated key changed in iCloud while the app stayed active.
        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreServerChange, changedKeys: [layoutKey])

        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])
        #expect(log.changes.contains { $0.contains(favoritesKey) })
    }
}
