//
//  FavoritesTests.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/01/2026.
//

import Foundation
import Testing
@testable import DrinkoPro

@Suite("Favorites behavior")
struct FavoritesTests {
    @Test("Add and remove toggles membership and persists")
    @MainActor
    func addRemove() throws {
        // Ensure clean state
        UserDefaults.standard.removeObject(forKey: "Cocktails")
        let favorites = Favorites()

        let cocktail = Cocktail(
            id: "negroni",
            name: "Negroni",
            method: "Stir",
            glass: "Rocks",
            garnish: "Orange peel",
            ice: "Cubed",
            extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 1.0, unit: "oz.")]
        )

        #expect(favorites.contains(cocktail) == false)
        favorites.add(cocktail)
        #expect(favorites.contains(cocktail) == true)
        #expect(favorites.hasEffect == true)
        favorites.remove(cocktail)
        #expect(favorites.contains(cocktail) == false)
        #expect(favorites.hasEffect == false)

        // Check persistence writes something
        favorites.add(cocktail)
        let data = UserDefaults.standard.data(forKey: "Cocktails")
        #expect(data != nil)
    }
}
