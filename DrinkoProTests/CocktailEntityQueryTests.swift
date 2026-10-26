import AppIntents
import Foundation
import Testing
@testable import DrinkoPro

@Suite("CocktailEntityQuery")
struct CocktailEntityQueryTests {
    private static func make(_ id: String, _ name: String, glass: String = "-") -> Cocktail {
        Cocktail(id: id, name: name, method: "stir", glass: glass, garnish: "-", ice: "-", extra: "-", ingredients: [])
    }

    private let zombie = make("zombie", "Zombie (1934)", glass: "tiki mug")
    private let cocktails = [
        make("zombie", "Zombie (1934)", glass: "tiki mug"),
        make("old-fashioned", "Old Fashioned"),
        make("b-52", "B-52", glass: "shot")
    ]

    @Test
    func matchingFallsBackToClosest() {
        #expect(CocktailEntityQuery.results(matching: "zombi", in: cocktails).map(\.id) == ["zombie"])
    }

    @Test
    func matchingReturnsEveryClosestTie() {
        let library = cocktails + [Self.make("sling", "Sling"), Self.make("fling", "Fling")]
        let ids = CocktailEntityQuery.results(matching: "kling", in: library).map(\.id)
        #expect(Set(ids) == ["sling", "fling"])
    }

    @Test
    func matchingNothingIsEmpty() {
        #expect(CocktailEntityQuery.results(matching: "spaghetti", in: cocktails).isEmpty)
    }

    @Test
    func entityTitleIsSpokenName() {
        let representation = CocktailEntity(zombie).displayRepresentation
        #expect(String(localized: representation.title) == "Zombie")
        let synonyms = representation.synonyms.map { String(localized: $0) }
        #expect(synonyms.contains("Zombie (1934)"))
    }

    @Test
    func synonymsIncludePunctuationStrippedName() {
        let entity = CocktailEntity(Self.make("corpse-reviver-2", "Corpse Reviver #2"))
        let synonyms = entity.displayRepresentation.synonyms.map { String(localized: $0) }
        #expect(synonyms.contains("Corpse Reviver 2"))
    }

    @Test
    func shotsAreDetectedByGlass() {
        #expect(CocktailEntity(cocktails[2]).isShot)
        #expect(!CocktailEntity(zombie).isShot)
    }
}
