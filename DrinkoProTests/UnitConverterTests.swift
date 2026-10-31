import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("UnitConverter")
struct UnitConverterTests {
    @Test("oz. to ml uses 30 ml per oz.")
    func convertOzToMlUsesBartendingMappings() {
        #expect(UnitConverter.convert(1.0, from: "oz.", to: "ml") == 30.0)
        #expect(UnitConverter.convert(1.5, from: "oz.", to: "ml") == 45.0)
    }

    @Test("oz. to ml rounds to the nearest 5 ml", arguments: [
        (0.75, 25.0), (0.25, 10.0), (1.25, 40.0), (1.75, 55.0), (2.25, 70.0), (0.35, 10.0), (1.15, 35.0)
    ])
    func convertOzToMlRoundsToFiveMl(ounces: Double, milliliters: Double) {
        #expect(UnitConverter.convert(ounces, from: "oz.", to: "ml") == milliliters)
    }

    @Test("ml to oz. rounds to the nearest quarter ounce", arguments: [
        (50.0, 1.75), (40.0, 1.25), (25.0, 0.75), (20.0, 0.75), (15.0, 0.5), (10.0, 0.25), (60.0, 2.0)
    ])
    func convertMlToOzRoundsToQuarterOunces(milliliters: Double, ounces: Double) {
        #expect(UnitConverter.convert(milliliters, from: "ml", to: "oz.") == ounces)
    }

    @Test("pours below the rounding step keep their own unit", arguments: [
        ("ml", 2.0, "oz."), ("oz.", 0.05, "ml")
    ])
    func smallPoursKeepTheirUnit(unit: String, quantity: Double, target: String) {
        let ingredient = Ingredient(name: "Absinthe", quantity: quantity, unit: unit)
        #expect(ingredient.convertedQuantity(to: target) == quantity)
        #expect(ingredient.convertedUnit(to: target) == unit)
    }

    @Test("the smallest step still converts")
    func smallestStepConverts() {
        #expect(UnitConverter.convert(0.15, from: "oz.", to: "ml") == 5.0)
        #expect(UnitConverter.convert(5, from: "ml", to: "oz.") == 0.25)
    }

    @Test("ml to oz. uses 30 ml per oz.")
    func convertMlToOzUsesBartendingMappings() {
        #expect(UnitConverter.convert(30.0, from: "ml", to: "oz.") == 1.0)
        #expect(UnitConverter.convert(52.5, from: "ml", to: "oz.") == 1.75)
    }

    @Test("unknown units pass through")
    func convertPassthroughForUnknownUnits() {
        #expect(UnitConverter.convert(10.0, from: "dash", to: "ml") == 10.0)
    }

    @Test("unit labels map for conversion")
    func unitLabelForConversion() {
        #expect(UnitConverter.unitLabel(for: "oz.", convertingTo: "ml") == "ml")
        #expect(UnitConverter.unitLabel(for: "ml", convertingTo: "oz.") == "oz.")
        #expect(UnitConverter.unitLabel(for: "dash", convertingTo: "ml") == "dash")
    }

    @Test("ingredient conversion uses UnitConverter")
    func ingredientConversionUsesUnitConverter() {
        let ingredient = Ingredient(name: "Gin", quantity: 50.0, unit: "ml")
        #expect(ingredient.convertedQuantity(to: "oz.") == 1.75)
        #expect(ingredient.convertedUnit(to: "oz.") == "oz.")

        let second = Ingredient(name: "Vermouth", quantity: 1.75, unit: "oz.")
        #expect(second.convertedQuantity(to: "ml") == 55.0)
        #expect(second.convertedUnit(to: "ml") == "ml")
    }
}
