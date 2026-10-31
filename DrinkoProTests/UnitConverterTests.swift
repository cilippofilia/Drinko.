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

    @Test("small pours never round to zero")
    func convertOzToMlKeepsSmallPours() {
        #expect(UnitConverter.convert(0.05, from: "oz.", to: "ml") == 5.0)
        #expect(UnitConverter.convert(0.15, from: "oz.", to: "ml") == 5.0)
        #expect(UnitConverter.convert(0, from: "oz.", to: "ml") == 0)
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
        #expect(ingredient.convertedQuantity(to: "oz.") == 50.0 / 30.0)
        #expect(ingredient.convertedUnit(to: "oz.") == "oz.")

        let second = Ingredient(name: "Vermouth", quantity: 1.75, unit: "oz.")
        #expect(second.convertedQuantity(to: "ml") == 55.0)
        #expect(second.convertedUnit(to: "ml") == "ml")
    }
}
