//
//  ModelsTests.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/01/2026.
//

import Foundation
import Testing
@testable import DrinkoPro

@Suite("Model sanity checks")
struct ModelsTests {
    @Test("Category suggested list")
    func categorySuggested() throws {
        let suggested = Category.suggestedCategories
        #expect(!suggested.isEmpty)
        #expect(suggested.contains { $0.name == "Vodkas" })
    }

    @Test("Item init and defaults")
    func itemDefaults() throws {
        let item = Item(name: "Absolut")
        #expect(item.name == "Absolut")
        #expect(item.tried == false)
        #expect(item.rating == 3)
        #expect(item.isFavorite == false)
    }

    @Test("Category relationship add/remove")
    func categoryRelationship() throws {
        let cat = Category(name: "Vodka", creationDate: .now)
        #expect((cat.products ?? []).isEmpty)
        let item = Item(name: "Absolut")
        cat.products?.append(item)
        #expect(cat.products?.contains(where: { $0.name == "Absolut" }) == true)
        cat.products?.removeAll(where: { $0.name == "Absolut" })
        #expect(cat.products?.contains(where: { $0.name == "Absolut" }) == false)
    }
}
