import Foundation
import Testing
@testable import DrinkoPro

@Suite("Cocktail unit preference")
struct CocktailUnitPreferenceTests {
    @Test(arguments: [("en_US", "oz."), ("en_GB", "ml"), ("it_IT", "ml"), ("de_DE", "ml")])
    func automaticFollowsTheRegionsMeasurementSystem(identifier: String, expected: String) {
        #expect(CocktailUnitPreference.automatic.unit(for: Locale(identifier: identifier)) == expected)
    }

    @Test func explicitChoiceIgnoresTheRegion() {
        let usLocale = Locale(identifier: "en_US")
        #expect(CocktailUnitPreference.milliliters.unit(for: usLocale) == "ml")
        #expect(CocktailUnitPreference.ounces.unit(for: Locale(identifier: "it_IT")) == "oz.")
    }
}
