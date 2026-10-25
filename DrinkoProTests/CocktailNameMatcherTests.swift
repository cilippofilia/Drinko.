import Foundation
import Testing
@testable import DrinkoPro

@Suite("CocktailNameMatcher")
struct CocktailNameMatcherTests {
    private static func make(_ id: String, _ name: String) -> Cocktail {
        Cocktail(id: id, name: name, method: "stir", glass: "-", garnish: "-", ice: "-", extra: "-", ingredients: [])
    }

    private let cocktails = [
        make("zombie", "Zombie (1934)"),
        make("old-fashioned", "Old Fashioned"),
        make("corpse-reviver-2", "Corpse Reviver #2"),
        make("dry-martini", "Dry Martini"),
        make("vodka-martini", "Vodka Martini")
    ]

    @Test
    func spokenNameDropsTheYear() {
        #expect(CocktailNameMatcher.spokenName("Zombie (1934)") == "Zombie")
    }

    @Test(arguments: ["zombie", "The Zombie", "zombie cocktail"])
    func matchesIgnoreCaseArticleAndSuffix(query: String) {
        #expect(CocktailNameMatcher.matches(query, in: cocktails).map(\.id) == ["zombie"])
    }

    @Test
    func matchesIgnorePunctuation() {
        #expect(CocktailNameMatcher.matches("corpse reviver 2", in: cocktails).map(\.id) == ["corpse-reviver-2"])
        #expect(CocktailNameMatcher.matches("oldfashioned", in: cocktails).map(\.id) == ["old-fashioned"])
    }

    @Test
    func ambiguousQueryReturnsAll() {
        let ids = CocktailNameMatcher.matches("martini", in: cocktails).map(\.id)
        #expect(Set(ids) == ["dry-martini", "vodka-martini"])
    }

    @Test
    func closestMatchCatchesTypos() {
        #expect(CocktailNameMatcher.closestMatch(to: "zombi", in: cocktails)?.id == "zombie")
    }

    @Test
    func closestMatchRejectsNonsense() {
        #expect(CocktailNameMatcher.closestMatch(to: "spaghetti", in: cocktails) == nil)
    }
}
