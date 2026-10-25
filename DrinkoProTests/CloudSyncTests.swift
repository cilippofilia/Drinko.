import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("CloudSync")
struct CloudSyncTests {
    private let favoritesKey = AppGroup.favoritesKey
    private let layoutKey = LibraryLayout.learnStorageKey
    private let otherLayoutKey = LibraryLayout.cocktailsStorageKey
    private let recentsKey = RecentsStore.storageKey(for: .cocktails)

    /// A fake iCloud store plus two throwaway `UserDefaults` suites standing in for
    /// `.standard` and the App Group.
    @MainActor
    private struct Harness {
        let cloud = InMemoryCloudKeyValueStore()
        let standard: UserDefaults
        let appGroup: UserDefaults
        let suiteNames: [String]

        func tearDown() {
            for name in suiteNames {
                UserDefaults().removePersistentDomain(forName: name)
            }
        }
    }

    /// Records what `onRemoteChange` reports.
    @MainActor
    private final class ChangeLog {
        var changes: [Set<String>] = []
    }

    private func makeHarness() throws -> Harness {
        let standardName = "CloudSyncTests.standard.\(UUID().uuidString)"
        let appGroupName = "CloudSyncTests.appGroup.\(UUID().uuidString)"
        return Harness(
            standard: try #require(UserDefaults(suiteName: standardName)),
            appGroup: try #require(UserDefaults(suiteName: appGroupName)),
            suiteNames: [standardName, appGroupName]
        )
    }

    private func makeSync(_ harness: Harness, log: ChangeLog? = nil) -> CloudSync {
        CloudSync(cloud: harness.cloud, standard: harness.standard, appGroup: harness.appGroup) { changed in
            log?.changes.append(changed)
        }
    }

    private func encoded(_ ids: Set<String>) throws -> Data {
        try JSONEncoder().encode(ids)
    }

    private func decoded(_ value: Any?) throws -> Set<String> {
        try JSONDecoder().decode(Set<String>.self, from: try #require(value as? Data))
    }

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

    // MARK: First sync

    @Test func firstStartMergesFavoritesIntoBothSides() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])
        let log = ChangeLog()

        let sync = makeSync(harness, log: log)
        sync.start()

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni", "daiquiri"])
        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni", "daiquiri"])
        #expect(harness.standard.bool(forKey: CloudSync.didInitialMergeKey))
        #expect(log.changes.last?.contains(favoritesKey) == true)
        #expect(harness.cloud.writes == [favoritesKey])
    }

    @Test func firstStartAdoptsCloudSettingsAndUploadsLocalOnes() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set("list", forKey: layoutKey)
        harness.cloud.values[layoutKey] = "grid"
        harness.standard.set("grid", forKey: otherLayoutKey)

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.standard.string(forKey: layoutKey) == "grid")
        #expect(harness.cloud.values[otherLayoutKey] as? String == "grid")
    }

    @Test func firstStartMergesRecents() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(["b", "c"], forKey: recentsKey)
        harness.cloud.values[recentsKey] = ["a", "b"]

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.standard.stringArray(forKey: recentsKey) == ["a", "b", "c"])
        #expect(harness.cloud.values[recentsKey] as? [String] == ["a", "b", "c"])
    }

    @Test func theFlagsStayLocal() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.awaitingFirstDownloadKey)

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.cloud.values[CloudSync.didInitialMergeKey] == nil)
        #expect(harness.cloud.values[CloudSync.awaitingFirstDownloadKey] == nil)
    }

    // MARK: Later launches

    @Test func laterStartsTakeCloudValuesWithoutMerging() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])
        let log = ChangeLog()

        let sync = makeSync(harness, log: log)
        sync.start()

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["daiquiri"])
        #expect(log.changes == [[favoritesKey]])
    }

    @Test func favoritesGoToTheAppGroupAndSettingsToStandard() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])
        harness.cloud.values[layoutKey] = "grid"

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.appGroup.object(forKey: favoritesKey) != nil)
        #expect(harness.standard.object(forKey: favoritesKey) == nil)
        #expect(harness.standard.string(forKey: layoutKey) == "grid")
        #expect(harness.appGroup.object(forKey: layoutKey) == nil)
    }

    // MARK: Local changes

    @Test func localWritesOfSyncedKeysAreUploaded() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        let sync = makeSync(harness)
        sync.start()
        harness.cloud.writes.removeAll()

        harness.standard.set("grid", forKey: layoutKey)
        harness.standard.set("whatever", forKey: "someUnsyncedKey")

        #expect(harness.cloud.values[layoutKey] as? String == "grid")
        #expect(harness.cloud.values["someUnsyncedKey"] == nil)
        #expect(harness.cloud.writes == [layoutKey])
    }

    @Test func pushLocalChangesOnlyUploadsWhatChanged() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        let sync = makeSync(harness)
        sync.start()
        harness.standard.set("grid", forKey: layoutKey)
        harness.cloud.writes.removeAll()

        sync.pushLocalChanges()

        #expect(harness.cloud.writes.isEmpty)
    }

    // MARK: Remote changes

    @Test func remoteChangeUpdatesLocalWithoutEcho() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        let log = ChangeLog()
        let sync = makeSync(harness, log: log)
        sync.start()
        harness.cloud.values[layoutKey] = "grid"
        harness.cloud.writes.removeAll()

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreServerChange, changedKeys: [layoutKey])

        #expect(harness.standard.string(forKey: layoutKey) == "grid")
        #expect(log.changes.last == [layoutKey])
        #expect(harness.cloud.writes.isEmpty)
    }

    @Test func invalidCloudValueIsSkipped() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        let sync = makeSync(harness)
        sync.start()
        harness.cloud.values[favoritesKey] = Data("junk".utf8)

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreServerChange, changedKeys: [favoritesKey])

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni"])
        #expect(harness.cloud.values[favoritesKey] as? Data == Data("junk".utf8))
    }

    @Test func invalidCloudValueIsSkippedOnFirstSync() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = Data("junk".utf8)

        let sync = makeSync(harness)
        sync.start()

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni"])
        #expect(harness.cloud.values[favoritesKey] as? Data == Data("junk".utf8))
    }

    @Test func serverChangeBeforeTheFirstMergeMerges() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        let sync = makeSync(harness)
        sync.start()
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreServerChange, changedKeys: [favoritesKey])

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni", "daiquiri"])
        #expect(harness.standard.bool(forKey: CloudSync.didInitialMergeKey))
    }

    @Test func initialSyncChangeMergesAgainAfterFirstMerge() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        let sync = makeSync(harness)
        sync.start()
        // iCloud discarded the launch upload and delivered what it already had.
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreInitialSyncChange, changedKeys: [favoritesKey])

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni", "daiquiri"])
        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni", "daiquiri"])
    }

    @Test func accountChangeMergesAgain() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.didInitialMergeKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        let sync = makeSync(harness)
        sync.start()
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreAccountChange, changedKeys: [favoritesKey])

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni", "daiquiri"])
        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni", "daiquiri"])
        #expect(harness.standard.bool(forKey: CloudSync.didInitialMergeKey))
    }

    // MARK: Waiting for iCloud's first download

    @Test func firstStartWithEmptyCloudWaitsForTheDownload() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)

        let sync = makeSync(harness)
        sync.start()

        #expect(harness.cloud.writes.isEmpty)
        #expect(!harness.standard.bool(forKey: CloudSync.didInitialMergeKey))
        #expect(harness.standard.bool(forKey: CloudSync.awaitingFirstDownloadKey))
    }

    @Test func localWritesWaitUntilTheFirstMerge() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        let sync = makeSync(harness)
        sync.start()

        harness.standard.set("grid", forKey: layoutKey)

        #expect(harness.cloud.writes.isEmpty)
    }

    @Test func aLaterLaunchWithEmptyCloudActsAsTheFirstDevice() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.standard.set(true, forKey: CloudSync.awaitingFirstDownloadKey)
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)

        let sync = makeSync(harness)
        sync.start()

        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni"])
        #expect(harness.standard.bool(forKey: CloudSync.didInitialMergeKey))
        #expect(!harness.standard.bool(forKey: CloudSync.awaitingFirstDownloadKey))
    }

    @Test func theFirstDownloadMergesWhateverItsReason() throws {
        let harness = try makeHarness()
        defer { harness.tearDown() }
        harness.appGroup.set(try encoded(["negroni"]), forKey: favoritesKey)
        let sync = makeSync(harness)
        sync.start()
        harness.cloud.values[favoritesKey] = try encoded(["daiquiri"])

        sync.handleCloudChange(reason: NSUbiquitousKeyValueStoreServerChange, changedKeys: [favoritesKey])

        #expect(try decoded(harness.appGroup.object(forKey: favoritesKey)) == ["negroni", "daiquiri"])
        #expect(try decoded(harness.cloud.values[favoritesKey]) == ["negroni", "daiquiri"])
        #expect(harness.standard.bool(forKey: CloudSync.didInitialMergeKey))
    }

    // MARK: Changes made outside the app

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
}
