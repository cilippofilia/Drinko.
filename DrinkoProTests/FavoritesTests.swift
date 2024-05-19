//
//  FavoritesTests.swift
//  DrinkoProTests
//
//  Created by Filippo Cilia on 19/05/2024.
//

import XCTest
@testable import DrinkoPro

final class FavoritesTests: XCTestCase {
    var favorites: Favorites!
    var mockUserDefaults: UserDefaults!
    let testCocktail = Cocktail(
        id: "test-cocktail",
        name: "Test Cocktail",
        method: "Shake",
        glass: "Highball",
        garnish: "Lime",
        ice: "Cubed",
        extra: "None",
        ingredients: []
    )

    override func setUpWithError() throws {
        mockUserDefaults = UserDefaults(suiteName: "MockUserDefaults")
        favorites = Favorites()
    }

    override func tearDownWithError() throws {
        favorites = nil
        mockUserDefaults.removePersistentDomain(forName: "MockUserDefaults")
        mockUserDefaults = nil
    }

    func testInitLoadsFavorites() {
        let encodedCocktails = try! JSONEncoder().encode(Set(["test-cocktail"]))
        mockUserDefaults.set(encodedCocktails, forKey: "Cocktails")

        favorites = Favorites()

        XCTAssertTrue(favorites.contains(testCocktail))
    }

    func testAddFavorite() {
        favorites.add(testCocktail)

        XCTAssertTrue(favorites.contains(testCocktail))
        XCTAssertTrue(favorites.hasEffect)
    }
}
