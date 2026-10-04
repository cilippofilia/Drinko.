import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("RecentsStore")
struct RecentsStoreTests {
    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "RecentsStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func startsEmpty() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        #expect(store.ids(in: .learn).isEmpty)
        #expect(store.ids(in: .cocktails).isEmpty)
    }

    @Test func recordPutsNewestFirst() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        store.record("a", in: .learn)
        store.record("b", in: .learn)
        #expect(store.ids(in: .learn) == ["b", "a"])
    }

    @Test func recordingAnExistingIDMovesItToFrontWithoutDuplicating() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        store.record("a", in: .learn)
        store.record("b", in: .learn)
        store.record("a", in: .learn)
        #expect(store.ids(in: .learn) == ["a", "b"])
    }

    @Test func keepsAtMostThree() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        for id in ["a", "b", "c", "d"] {
            store.record(id, in: .cocktails)
        }
        #expect(store.ids(in: .cocktails) == ["d", "c", "b"])
    }

    @Test func namespacesAreIsolated() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        store.record("lesson:ice", in: .learn)
        store.record("negroni", in: .cocktails)
        #expect(store.ids(in: .learn) == ["lesson:ice"])
        #expect(store.ids(in: .cocktails) == ["negroni"])
    }

    @Test func persistsAcrossInstances() throws {
        let defaults = try makeDefaults()
        RecentsStore(defaults: defaults).record("negroni", in: .cocktails)
        #expect(RecentsStore(defaults: defaults).ids(in: .cocktails) == ["negroni"])
    }

    @Test func truncatesOverlongStoredLists() throws {
        let defaults = try makeDefaults()
        defaults.set(["a", "b", "c", "d", "e"], forKey: "recents.learn")
        #expect(RecentsStore(defaults: defaults).ids(in: .learn) == ["a", "b", "c"])
    }
}
