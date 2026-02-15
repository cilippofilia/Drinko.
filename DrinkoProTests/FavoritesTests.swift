import Testing
import Foundation
@testable import DrinkoPro

struct FavoritesTests {
    private let defaultsKey = "Cocktails"

    @Test @MainActor func addAndContainsCocktail() {
        clearDefaults()
        defer { clearDefaults() }

        let favorites = Favorites()
        let cocktail = makeCocktail(id: "negroni")

        #expect(favorites.contains(cocktail) == false)
        #expect(favorites.hasEffect == false)

        favorites.add(cocktail)

        #expect(favorites.contains(cocktail) == true)
        #expect(favorites.hasEffect == true)
    }

    @Test @MainActor func removeCocktail() {
        clearDefaults()
        defer { clearDefaults() }

        let favorites = Favorites()
        let cocktail = makeCocktail(id: "martini")

        favorites.add(cocktail)
        #expect(favorites.contains(cocktail) == true)

        favorites.remove(cocktail)

        #expect(favorites.contains(cocktail) == false)
        #expect(favorites.hasEffect == false)
    }

    @Test @MainActor func persistenceAcrossInstances() {
        clearDefaults()
        defer { clearDefaults() }

        let cocktail = makeCocktail(id: "daiquiri")

        let first = Favorites()
        first.add(cocktail)

        let second = Favorites()
        #expect(second.contains(cocktail) == true)

        second.remove(cocktail)
        let third = Favorites()
        #expect(third.contains(cocktail) == false)
    }

    private func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    private func makeCocktail(id: String) -> Cocktail {
        Cocktail(
            id: id,
            name: "Test Cocktail",
            method: "Shake",
            glass: "Coupe",
            garnish: "None",
            ice: "None",
            extra: "",
            ingredients: [
                Ingredient(name: "Gin", quantity: 1.0, unit: "oz.")
            ]
        )
    }
}
