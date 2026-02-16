import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("UnitConverter")
struct UnitConverterTests {
    @Test("oz. to ml uses precise conversion")
    func convertOzToMlUsesBartendingMappings() {
        let oneOz = Measurement(value: 1.0, unit: UnitVolume.fluidOunces)
            .converted(to: .milliliters)
            .value
        let oneAndThreeQuarters = Measurement(value: 1.75, unit: UnitVolume.fluidOunces)
            .converted(to: .milliliters)
            .value
        #expect(abs(UnitConverter.convert(1.0, from: "oz.", to: "ml") - oneOz) < 0.000001)
        #expect(abs(UnitConverter.convert(1.75, from: "oz.", to: "ml") - oneAndThreeQuarters) < 0.000001)
    }

    @Test("ml to oz. uses precise conversion")
    func convertMlToOzUsesBartendingMappings() {
        let oneMl = Measurement(value: 29.5735295625, unit: UnitVolume.milliliters)
            .converted(to: .fluidOunces)
            .value
        let oneAndThreeQuarters = Measurement(value: 51.753676734375, unit: UnitVolume.milliliters)
            .converted(to: .fluidOunces)
            .value
        #expect(abs(UnitConverter.convert(29.5735295625, from: "ml", to: "oz.") - oneMl) < 0.000001)
        #expect(abs(UnitConverter.convert(51.753676734375, from: "ml", to: "oz.") - oneAndThreeQuarters) < 0.000001)
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
        let expectedGin = Measurement(value: 50.0, unit: UnitVolume.milliliters)
            .converted(to: .fluidOunces)
            .value
        #expect(abs(ingredient.convertedQuantity(to: "oz.") - expectedGin) < 0.000001)
        #expect(ingredient.convertedUnit(to: "oz.") == "oz.")

        let second = Ingredient(name: "Vermouth", quantity: 1.75, unit: "oz.")
        let expectedVermouth = Measurement(value: 1.75, unit: UnitVolume.fluidOunces)
            .converted(to: .milliliters)
            .value
        #expect(abs(second.convertedQuantity(to: "ml") - expectedVermouth) < 0.000001)
        #expect(second.convertedUnit(to: "ml") == "ml")
    }
}
