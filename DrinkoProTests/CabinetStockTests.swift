//
//  CabinetStockTests.swift
//  DrinkoProTests
//

import Testing
@testable import DrinkoPro

@Suite("CabinetStock") struct CabinetStockTests {
    @Test func spiritsResolveFromCategoryOrName() {
        let stock = CabinetStock(bottles: [("Absolut", "Vodkas"), ("Bombay Sapphire", "Gins"), ("Lagavulin", nil)])
        #expect(stock.spirits == [.vodka, .gin])  // "Lagavulin" alone names no spirit
        #expect(stock.covers("citron vodka"))
        #expect(stock.covers("london dry gin"))
    }

    @Test func stylesNeedTheRightQualifier() {
        let stock = CabinetStock(bottles: [("Carpano Antica", "Vermouth")])
        #expect(stock.covers("sweet red vermouth"))
        #expect(!stock.covers("dry vermouth"))
    }

    @Test func uncategorisedItemCountsByName() {
        #expect(CabinetStock(bottles: [("Campari", nil)]).covers("campari"))
    }

    @Test func fallbackNeedsTheFullName() {
        let stock = CabinetStock(bottles: [("Some Rare Amaro 1888", "Amari")])
        #expect(stock.covers("some rare amaro"))
        #expect(!stock.covers("rare whisky liqueur"))
    }

    @Test func alternativesAndStaples() {
        let stock = CabinetStock(bottles: [("Rittenhouse Rye", "Whiskeys")])
        #expect(stock.covers("bourbon or rye whiskey"))
        #expect(CabinetStock(bottles: []).covers("lime juice"))
    }
}
