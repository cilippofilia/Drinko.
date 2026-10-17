//
//  IngredientLine.swift
//  DrinkoPro
//

import Foundation

/// An ingredient converted to the user's unit, except in the user's own cocktails, which keep
/// the units they were written in.
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
