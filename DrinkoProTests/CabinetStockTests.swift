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

    @Test func alternatives() {
        let stock = CabinetStock(bottles: [("Rittenhouse Rye", "Whiskeys")])
        #expect(stock.covers("bourbon or rye whiskey"))
    }

    @Test func staplesMustBeInTheCabinet() {
        #expect(!CabinetStock(bottles: []).covers("lime juice"))
        #expect(CabinetStock(bottles: [("Fresh Lime Juice", "Juices")]).covers("lime juice"))
        #expect(CabinetStock(bottles: [("Fresh Mint", "Garnishes")]).covers("mint"))
        #expect(!CabinetStock(bottles: [("Peppermint Schnapps", "Liqueurs")]).covers("mint"))
        #expect(!CabinetStock(bottles: [("Limes", "Fruit")]).covers("lime juice"))
    }

    @Test func mixersInTheCabinetAreNotSpirits() {
        #expect(CabinetStock(bottles: [("Fever-Tree Ginger Beer", "Mixers")]).spirits.isEmpty)
    }

    @Test(arguments: [
        ("Marie Brizard Apricot Brandy", "Brandy", "apricot brandy"),
        ("De Kuyper Cherry Brandy", "Brandy", "cherry brandy"),
        ("Plymouth Sloe Gin", "Gin", "sloe gin"),
        ("Marie Brizard Apricot Brandy", nil, "apricot brandy"),
        ("De Kuyper Cherry Brandy", nil, "cherry brandy"),
        ("Plymouth Sloe Gin", nil, "sloe gin")
    ] as [(String, String?, String)])
    func liqueursAreNotBaseSpirits(name: String, category: String?, recipe: String) {
        let stock = CabinetStock(bottles: [(name, category)])
        #expect(stock.spirits.isEmpty)
        #expect(stock.covers(recipe))
        #expect(!stock.covers("gin"))
        #expect(!stock.covers("cognac"))
    }

    @Test func gingerBrandyIsNotACognac() {
        #expect(CabinetStock(bottles: [("Canton Ginger Brandy", "Brandy")]).spirits.isEmpty)
        #expect(RecipeBottle(name: "ginger brandy") != .spirit(.cognac))
    }

    @Test func fallbackSearchesTheNameOnly() {
        #expect(!CabinetStock(bottles: [("Campari", "Bitters")]).covers("bitters"))
        #expect(!CabinetStock(bottles: [("Baileys", "Liqueurs")]).covers("liqueur"))
    }

    @Test func baileysCoversBaileysRecipeSpelling() {
        #expect(CabinetStock(bottles: [("Baileys", "Liqueurs")]).covers("Bailey's"))
    }

    @Test func pluralsSingularise() {
        #expect(CabinetStock(bottles: [("House Pour", "Gins")]).spirits == [.gin])
        #expect(CabinetStock(bottles: [("Angostura", "Bitters")]).spirits.isEmpty)
        #expect(CabinetStock(bottles: [("Peychaud's", "Bitters")]).spirits.isEmpty)
    }
}
