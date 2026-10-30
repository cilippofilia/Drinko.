//
//  CabinetDiscoveryTests.swift
//  DrinkoProTests
//

import Testing
@testable import DrinkoPro

@Suite("CabinetDiscovery") struct CabinetDiscoveryTests {
    private static func cocktail(_ id: String, _ ingredients: [String]) -> Cocktail {
        Cocktail(
            id: id, name: id, method: "", glass: "", garnish: "", ice: "", extra: "",
            ingredients: ingredients.map { Ingredient(name: $0, quantity: 1, unit: "oz") }
        )
    }

    private static let negroni = cocktail("negroni", ["london dry gin", "campari", "sweet red vermouth"])
    private static let daiquiri = cocktail("daiquiri", ["white rum", "lime juice", "simple syrup"])
    private static let vieuxCarre = cocktail(
        "vieux-carre", ["rye whiskey", "cognac", "sweet red vermouth", "dom benedictine"]
    )
    private static let virgin = cocktail("virgin", ["lime juice", "soda water"])

    @Test func makeNow() {
        let stock = CabinetStock(bottles: [("Tanqueray", "Gins"), ("Campari", nil), ("Martini Rosso", nil)])
        let result = CabinetDiscovery.discover(in: [Self.negroni, Self.daiquiri, Self.virgin], stock: stock)
        #expect(result.makeNow.map(\.cocktail.id) == ["negroni"])
        #expect(result.makeNow.first?.swap == nil)
    }

    @Test func twistSwapsOnlySensiblePairs() {
        let stock = CabinetStock(bottles: [
            ("Olmeca", "Tequilas & Mezcals"), ("Absolut", "Vodkas"), ("Campari", nil), ("Carpano Antica", nil)
        ])
        let twist = CabinetDiscovery.discover(in: [Self.negroni], stock: stock).twists.first
        #expect(twist?.swap == SpiritSwap(missing: .gin, substitutes: [.vodka, .tequila]))
    }

    @Test func noTwistWhenSubstituteIsAlreadyInTheDrink() {
        let stock = CabinetStock(bottles: [("Hennessy", "Cognacs"), ("Carpano Antica", nil), ("Bénédictine", nil)])
        #expect(CabinetDiscovery.discover(in: [Self.vieuxCarre], stock: stock).twists.isEmpty)
    }

    @Test func noTwistWhenTwoBottlesAreMissing() {
        let stock = CabinetStock(bottles: [("Olmeca", "Tequilas"), ("Campari", nil)])
        let result = CabinetDiscovery.discover(in: [Self.negroni], stock: stock)
        #expect(result.makeNow.isEmpty && result.twists.isEmpty)
    }

    @Test func noTwistWhenTheMissingBottleIsNotASpirit() {
        let stock = CabinetStock(bottles: [("Tanqueray", "Gins"), ("Olmeca", "Tequilas"), ("Carpano Antica", nil)])
        let result = CabinetDiscovery.discover(in: [Self.negroni], stock: stock)
        #expect(result.makeNow.isEmpty && result.twists.isEmpty)
    }

    @Test func noTwistForUnpairedSpirit() {
        let stock = CabinetStock(bottles: [("Absolut", "Vodkas")])
        #expect(CabinetDiscovery.discover(in: [Self.daiquiri], stock: stock).twists.isEmpty)
    }

    @Test func noTwistForFlavouredSpirit() {
        let stock = CabinetStock(bottles: [("Jameson", "Whiskeys")])
        let coconut = Self.cocktail("painkiller", ["coconut rum", "lime juice"])
        let plain = Self.cocktail("plain", ["white rum", "lime juice"])
        let result = CabinetDiscovery.discover(in: [coconut, plain], stock: stock)
        #expect(result.twists.map(\.cocktail.id) == ["plain"])
    }

    @Test func emptyCabinetFindsNothing() {
        let result = CabinetDiscovery.discover(
            in: [Self.negroni, Self.daiquiri, Self.virgin], stock: CabinetStock(bottles: [])
        )
        #expect(result.makeNow.isEmpty && result.twists.isEmpty)
    }

    @Test func swapMessage() {
        #expect(SpiritSwap(missing: .gin, substitutes: [.tequila]).message == "Use Tequila instead of Gin")
    }

    @MainActor @Test func discoverySelectionRoundTripsItsID() {
        #expect(ToolsView.Selection(id: "discovery") == .cabinetDiscovery)
        #expect(ToolsLibrary.sections.first?.id == ToolsLibrary.discoverSectionID)
    }
}
