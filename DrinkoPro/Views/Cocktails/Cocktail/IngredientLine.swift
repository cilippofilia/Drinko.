//
//  IngredientLine.swift
//  DrinkoPro
//

import Foundation

/// An ingredient converted to the user's unit.
struct IngredientLine: Identifiable, Equatable {
    let id: String
    let quantity: Double
    let unit: String
    let name: String

    @MainActor
    init(ingredient: Ingredient, selectedUnit: String) {
        id = ingredient.id
        quantity = ingredient.convertedQuantity(to: selectedUnit)
        unit = ingredient.convertedUnit(to: selectedUnit)
        name = ingredient.name.capitalized
    }
}
