import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("IngredientLine")
struct IngredientLineTests {
    @Test func convertsToTheSelectedUnit() {
        let line = IngredientLine(
            ingredient: Ingredient(name: "london dry gin", quantity: 2, unit: "oz."),
            selectedUnit: "ml",
            showsOriginalUnits: false
        )
        #expect(line.quantity == 60)
        #expect(line.unit == "ml")
        #expect(line.name == "London Dry Gin")
    }

    @Test func keepsOriginalUnitsWhenAsked() {
        let line = IngredientLine(
            ingredient: Ingredient(name: "light rum", quantity: 1.5, unit: "oz."),
            selectedUnit: "ml",
            showsOriginalUnits: true
        )
        #expect(line.quantity == 1.5)
        #expect(line.unit == "oz.")
    }

    @Test func unconvertibleUnitPassesThrough() {
        let line = IngredientLine(
            ingredient: Ingredient(name: "angostura bitters", quantity: 2, unit: "dash"),
            selectedUnit: "ml",
            showsOriginalUnits: false
        )
        #expect(line.quantity == 2)
        #expect(line.unit == "dash")
    }

    @Test func idMatchesTheIngredient() {
        let ingredient = Ingredient(name: "cointreau", quantity: 1, unit: "oz.")
        let line = IngredientLine(ingredient: ingredient, selectedUnit: "ml", showsOriginalUnits: false)
        #expect(line.id == ingredient.id)
    }
}
