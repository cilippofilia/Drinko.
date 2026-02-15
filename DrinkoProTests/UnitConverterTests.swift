import Testing
@testable import DrinkoPro

struct UnitConverterTests {
    @Test @MainActor func convertOzToMlStandardFractions() {
        #expect(abs(UnitConverter.convert(1.75, from: "oz.", to: "ml") - 50.0) < 0.0001)
        #expect(abs(UnitConverter.convert(1.25, from: "oz.", to: "ml") - 40.0) < 0.0001)
        #expect(abs(UnitConverter.convert(0.75, from: "oz.", to: "ml") - 25.0) < 0.0001)
        #expect(abs(UnitConverter.convert(0.66, from: "oz.", to: "ml") - 20.0) < 0.0001)
        #expect(abs(UnitConverter.convert(0.33, from: "oz.", to: "ml") - 10.0) < 0.0001)
        #expect(abs(UnitConverter.convert(0.15, from: "oz.", to: "ml") - 5.0) < 0.0001)
    }

    @Test @MainActor func convertOzToMlFallbackUsesStandardMultiplier() {
        #expect(abs(UnitConverter.convert(2.0, from: "oz.", to: "ml") - 60.0) < 0.0001)
    }

    @Test @MainActor func convertSameUnitsReturnsOriginalQuantity() {
        #expect(abs(UnitConverter.convert(2.5, from: "ml", to: "ml") - 2.5) < 0.0001)
    }

    @Test @MainActor func unitLabelConversion() {
        #expect(UnitConverter.unitLabel(for: "oz.", convertingTo: "ml") == "ml")
        #expect(UnitConverter.unitLabel(for: "ml", convertingTo: "ml") == "ml")
    }
}
