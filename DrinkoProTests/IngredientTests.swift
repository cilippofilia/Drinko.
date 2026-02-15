import Testing
@testable import DrinkoPro

struct IngredientTests {
    @Test @MainActor func mlQuantityConvertsOzToMl() {
        let ingredient = Ingredient(name: "Gin", quantity: 1.5, unit: "oz.")
        #expect(abs(ingredient.mlQuantity - 45.0) < 0.0001)
    }

    @Test @MainActor func mlQuantityReturnsOriginalForNonOzUnits() {
        let ingredient = Ingredient(name: "Syrup", quantity: 15.0, unit: "ml")
        #expect(abs(ingredient.mlQuantity - 15.0) < 0.0001)
    }

    @Test @MainActor func mlUnitUsesConverterLabel() {
        let ingredient = Ingredient(name: "Gin", quantity: 1.0, unit: "oz.")
        #expect(ingredient.mlUnit == "ml")
    }
}
