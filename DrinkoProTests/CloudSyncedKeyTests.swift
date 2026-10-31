import Testing
@testable import DrinkoPro

@Suite("CloudSyncedKey")
struct CloudSyncedKeyTests {
    // Renaming any of these would orphan data users already have, locally and in iCloud.
    @Test func keysKeepTheirNames() {
        #expect(CloudSyncedKey.all.map(\.name) == [
            "Cocktails",
            "recents.learn",
            "recents.cocktails",
            "cocktailListSource",
            "cocktailUnitPreference",
            "learnLibraryLayout",
            "cocktailsLibraryLayout",
            "discoveryLibraryLayout",
            "learnCollapsedSections",
            "cocktailsCollapsedSections",
            "detailCollapsedSections"
        ])
    }

    @Test func onlyFavoritesLiveInTheAppGroup() {
        let appGroupKeys = CloudSyncedKey.all.filter { $0.suite == .appGroup }.map(\.name)
        #expect(appGroupKeys == ["Cocktails"])
    }

    @Test func rulesMatchTheValueKinds() {
        let rules = Dictionary(uniqueKeysWithValues: CloudSyncedKey.all.map { ($0.name, $0.rule) })
        #expect(rules["Cocktails"] == .favorites)
        #expect(rules["recents.learn"] == .recents)
        #expect(rules["recents.cocktails"] == .recents)
        #expect(CloudSyncedKey.all.filter { $0.rule == .setting }.count == 8)
    }
}
