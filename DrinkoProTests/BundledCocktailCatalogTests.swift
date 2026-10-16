//
//  BundledCocktailCatalogTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("BundledCocktailCatalog")
struct BundledCocktailCatalogTests {
    private let catalog = BundledCocktailCatalog.load()

    @Test func findsCocktail() throws {
        let cocktail = try #require(catalog.cocktail(withID: "negroni"))
        #expect(cocktail.name == "Negroni")
    }

    @Test func findsShots() throws {
        let shots = Bundle.main.decode([Cocktail].self, from: "shots.json")
        let shot = try #require(shots.first)
        #expect(catalog.cocktail(withID: shot.id) == shot)
    }

    @Test func unknownIDIsNil() {
        #expect(catalog.cocktail(withID: "not-a-real-cocktail") == nil)
    }

    @Test func resolvesHistoryAndProcedure() throws {
        let cocktail = try #require(catalog.cocktail(withID: "negroni"))
        #expect(catalog.history(for: cocktail)?.id == "negroni")
        #expect(catalog.procedure(for: cocktail)?.id == "negroni")
    }

    @Test func lookupUsesInjectedData() {
        let cocktail = Cocktail.example
        let small = BundledCocktailCatalog(cocktails: [cocktail], histories: [], procedures: [])
        #expect(small.cocktail(withID: cocktail.id) == cocktail)
        #expect(small.history(for: cocktail) == nil)
    }
}
