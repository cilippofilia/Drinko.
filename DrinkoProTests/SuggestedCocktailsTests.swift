import Foundation
import Testing
@testable import DrinkoPro

@Suite("SuggestedCocktails")
struct SuggestedCocktailsTests {
    private static func make(_ id: String, _ name: String) -> Cocktail {
        Cocktail(id: id, name: name, method: "stir", glass: "-", garnish: "-", ice: "-", extra: "-", ingredients: [])
    }

    private let library = [
        make("negroni", "Negroni"),
        make("old-fashioned", "Old Fashioned"),
        make("zombie", "Zombie (1934)"),
        make("aviation", "Aviation"),
        make("bijou", "Bijou"),
        make("user-1", "House Sour")
    ]

    @Test
    func recentsComeFirstThenFavouritesByNameThenClassics() {
        let ids = SuggestedCocktails.pick(
            recents: ["user-1"],
            favorites: ["bijou", "aviation"],
            from: library
        ).map(\.id)
        #expect(ids == ["user-1", "aviation", "bijou", "negroni", "old-fashioned", "zombie"])
    }

    @Test
    func duplicatesAppearOnce() {
        let ids = SuggestedCocktails.pick(
            recents: ["negroni", "negroni"],
            favorites: ["negroni"],
            from: library
        ).map(\.id)
        #expect(ids.filter { $0 == "negroni" }.count == 1)
    }

    @Test
    func missingDrinksAreSkipped() {
        let ids = SuggestedCocktails.pick(recents: ["deleted"], favorites: ["gone"], from: library).map(\.id)
        #expect(!ids.contains("deleted"))
        #expect(!ids.contains("gone"))
    }

    @Test
    func listStopsAtLimit() {
        let ids = SuggestedCocktails.pick(
            recents: ["bijou", "aviation"],
            favorites: ["user-1"],
            from: library,
            limit: 2
        ).map(\.id)
        #expect(ids == ["bijou", "aviation"])
    }

    @Test
    func emptyHistoryFallsBackToClassics() {
        let ids = SuggestedCocktails.pick(recents: [], favorites: [], from: library).map(\.id)
        #expect(ids == ["negroni", "old-fashioned", "zombie"])
    }

    @Test
    func everyClassicIsInTheBundledLibrary() {
        let ids = Set(ContentSnapshot.bundled().cocktails.map(\.id))
        #expect(SuggestedCocktails.classicIDs.allSatisfy(ids.contains))
        #expect(SuggestedCocktails.classicIDs.count <= SuggestedCocktails.limit)
    }
}
