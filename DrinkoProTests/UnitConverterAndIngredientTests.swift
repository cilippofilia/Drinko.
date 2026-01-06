//
//  UnitConverterTests.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/01/2026.
//

import Testing
@testable import DrinkoPro

@Suite("UnitConverter Tests")
@MainActor
struct UnitConverterTests {
    @Test("Common oz to ml conversions")
    func commonOzToMl() throws {
        #expect(UnitConverter.convert(1.75, from: "oz.", to: "ml") == 50.0)
        #expect(UnitConverter.convert(1.25, from: "oz.", to: "ml") == 40.0)
        #expect(UnitConverter.convert(0.75, from: "oz.", to: "ml") == 25.0)
        #expect(UnitConverter.convert(0.66, from: "oz.", to: "ml") == 20.0)
        #expect(UnitConverter.convert(0.33, from: "oz.", to: "ml") == 10.0)
    }

    @Test("Default oz to ml multiplier")
    func defaultMultiplier() throws {
        #expect(UnitConverter.convert(0.5, from: "oz.", to: "ml") == 15.0)
        #expect(UnitConverter.convert(2.0, from: "oz.", to: "ml") == 60.0)
    }

    @Test("Identity conversion and labels")
    func identityAndLabels() throws {
        #expect(UnitConverter.convert(10.0, from: "ml", to: "ml") == 10.0)
        #expect(UnitConverter.unitLabel(for: "oz.", convertingTo: "ml") == "ml")
        #expect(UnitConverter.unitLabel(for: "ml", convertingTo: "ml") == "ml")
    }
}

@Suite("Ingredient computed properties")
struct IngredientComputedPropertyTests {
    @Test
    @MainActor
    func mlQuantityAndUnitForOz() throws {
        let ing = Ingredient(name: "Gin", quantity: 1.75, unit: "oz.")
        #expect(ing.mlQuantity == 50.0)
        #expect(ing.mlUnit == "ml")
    }

    @Test
    @MainActor
    func mlQuantityAndUnitForMl() throws {
        let ing = Ingredient(name: "Vodka", quantity: 30.0, unit: "ml")
        #expect(ing.mlQuantity == 30.0)
        #expect(ing.mlUnit == "ml")
    }
}

