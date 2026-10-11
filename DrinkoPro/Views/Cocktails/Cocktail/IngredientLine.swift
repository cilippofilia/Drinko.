//
//  IngredientLine.swift
//  DrinkoPro
//

import Foundation

/// An ingredient as it's displayed: converted to the user's unit, or left in the units it was
/// written in (the user's own cocktails), with a capitalized name.
struct IngredientLine: Identifiable, Equatable {
    let id: String
    let quantity: Double
    let unit: String
    let name: String

    @MainActor
    init(ingredient: Ingredient, selectedUnit: String, showsOriginalUnits: Bool) {
        id = ingredient.id
        quantity = showsOriginalUnits ? ingredient.quantity : ingredient.convertedQuantity(to: selectedUnit)
        unit = showsOriginalUnits ? ingredient.unit : ingredient.convertedUnit(to: selectedUnit)
        name = ingredient.name.capitalized
    }
}
