import Foundation
import Testing
@testable import DrinkoPro

@Suite("CloudSyncMerge")
struct CloudSyncMergeTests {
    private func encoded(_ ids: Set<String>) throws -> Data {
        try JSONEncoder().encode(ids)
    }

    private func decoded(_ data: Any?) throws -> Set<String> {
        try JSONDecoder().decode(Set<String>.self, from: try #require(data as? Data))
    }

    // MARK: Favorites

    @Test func favoritesAreUnioned() throws {
        let merged = CloudSyncMerge.favorites(
            local: try encoded(["negroni"]),
            cloud: try encoded(["daiquiri", "negroni"])
        )
        #expect(try decoded(merged) == ["negroni", "daiquiri"])
    }

    @Test func favoritesFromOneSideAreKept() throws {
        #expect(try decoded(CloudSyncMerge.favorites(local: nil, cloud: try encoded(["daiquiri"]))) == ["daiquiri"])
        #expect(try decoded(CloudSyncMerge.favorites(local: try encoded(["negroni"]), cloud: nil)) == ["negroni"])
    }

    @Test func favoritesWithNothingOnEitherSideIsNil() {
        #expect(CloudSyncMerge.favorites(local: nil, cloud: nil) == nil)
    }

    @Test func favoritesEncodeTheSameSetTheSameWay() throws {
        let first = CloudSyncMerge.favorites(local: try encoded(["b", "a", "c"]), cloud: nil)
        let second = CloudSyncMerge.favorites(local: nil, cloud: try encoded(["c", "b", "a"]))
        #expect(first == second)
    }

    @Test func unknownFavoriteIDsAreKept() throws {
        let merged = CloudSyncMerge.favorites(
            local: try encoded(["user-cocktail-not-synced-yet"]),
            cloud: try encoded(["negroni"])
        )
        #expect(try decoded(merged).contains("user-cocktail-not-synced-yet"))
    }

    @Test func unreadableLocalFavoritesCountAsEmpty() throws {
        let merged = CloudSyncMerge.favorites(local: Data("junk".utf8), cloud: try encoded(["negroni"]))
        #expect(try decoded(merged) == ["negroni"])
    }

    // MARK: Recents

    @Test func recentsPutCloudFirstThenNewLocalOnes() {
        #expect(CloudSyncMerge.recents(local: ["b", "c"], cloud: ["a", "b"], capacity: 9) == ["a", "b", "c"])
    }

    @Test func recentsAreCappedAtCapacity() {
        let local = ["l1", "l2", "l3", "l4", "l5", "l6", "l7", "l8", "l9"]
        let merged = CloudSyncMerge.recents(local: local, cloud: ["c1", "c2", "c3"], capacity: 9)
        #expect(merged == ["c1", "c2", "c3", "l1", "l2", "l3", "l4", "l5", "l6"])
    }

    // MARK: Settings

    @Test func cloudSettingWins() {
        #expect(CloudSyncMerge.setting(local: "list", cloud: "grid") == "grid")
    }

    @Test func localSettingIsUsedWhenCloudHasNone() {
        #expect(CloudSyncMerge.setting(local: "list", cloud: nil) == "list")
        #expect(CloudSyncMerge.setting(local: nil, cloud: nil) == nil)
    }

    // MARK: Validation and first sync

    @Test func validityChecksTheValueKind() throws {
        #expect(CloudSyncMerge.isValid(try encoded(["negroni"]), for: .favorites))
        #expect(!CloudSyncMerge.isValid(Data("junk".utf8), for: .favorites))
        #expect(!CloudSyncMerge.isValid("negroni", for: .favorites))
        #expect(CloudSyncMerge.isValid(["a"], for: .recents))
        #expect(!CloudSyncMerge.isValid("a", for: .recents))
        #expect(CloudSyncMerge.isValid("grid", for: .setting))
        #expect(!CloudSyncMerge.isValid(5, for: .setting))
    }

    @Test func firstSyncSkipsInvalidCloudValues() throws {
        #expect(CloudSyncMerge.firstSync(
            local: try encoded(["negroni"]),
            cloud: Data("junk".utf8),
            rule: .favorites,
            recentsCapacity: 9
        ) == nil)
        #expect(CloudSyncMerge.firstSync(local: ["a"], cloud: "a", rule: .recents, recentsCapacity: 9) == nil)
        #expect(CloudSyncMerge.firstSync(local: "list", cloud: 5, rule: .setting, recentsCapacity: 9) == nil)
    }

    @Test func firstSyncWithNothingAnywhereIsNil() {
        #expect(CloudSyncMerge.firstSync(local: nil, cloud: nil, rule: .favorites, recentsCapacity: 9) == nil)
        #expect(CloudSyncMerge.firstSync(local: nil, cloud: nil, rule: .recents, recentsCapacity: 9) == nil)
        #expect(CloudSyncMerge.firstSync(local: nil, cloud: nil, rule: .setting, recentsCapacity: 9) == nil)
    }

    @Test func firstSyncAppliesEachRule() throws {
        let favorites = CloudSyncMerge.firstSync(
            local: try encoded(["negroni"]),
            cloud: try encoded(["daiquiri"]),
            rule: .favorites,
            recentsCapacity: 9
        )
        #expect(try decoded(favorites) == ["negroni", "daiquiri"])

        let recents = CloudSyncMerge.firstSync(local: ["b"], cloud: ["a"], rule: .recents, recentsCapacity: 9)
        #expect(recents as? [String] == ["a", "b"])

        let setting = CloudSyncMerge.firstSync(local: "list", cloud: "grid", rule: .setting, recentsCapacity: 9)
        #expect(setting as? String == "grid")
    }
}
