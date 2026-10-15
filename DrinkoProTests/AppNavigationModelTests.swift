//
//  AppNavigationModelTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("AppNavigationModel")
struct AppNavigationModelTests {
    @Test func newCocktailSwitchesToCocktails() {
        let model = AppNavigationModel()
        model.selectedTab = .learn

        model.requestNewCocktail()

        #expect(model.selectedTab == .cocktails)
        #expect(model.pendingCreation == .cocktail)
    }

    @Test func newCocktailKeepsCurrentCocktailsPage() {
        let model = AppNavigationModel()
        model.selectedTab = .cocktailFilter(.shotsOnly)

        model.requestNewCocktail()

        #expect(model.selectedTab == .cocktailFilter(.shotsOnly))
        #expect(model.pendingCreation == .cocktail)
    }

    @Test func newCategoryAlwaysOpensMainCabinet() {
        let model = AppNavigationModel()
        model.selectedTab = .cabinetCategory(UUID())

        model.requestNewCategory()

        #expect(model.selectedTab == .cabinet)
        #expect(model.pendingCreation == .category)
    }

    @Test func consumeIsOneShot() {
        let model = AppNavigationModel()
        model.requestNewCocktail()

        #expect(model.consumePendingCreation(.cocktail))
        #expect(model.pendingCreation == nil)
        #expect(model.consumePendingCreation(.cocktail) == false)
    }

    @Test func consumeIgnoresOtherRequests() {
        let model = AppNavigationModel()
        model.requestNewCategory()

        #expect(model.consumePendingCreation(.cocktail) == false)
        #expect(model.pendingCreation == .category)
    }
}
