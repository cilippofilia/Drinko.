//
//  UserIngredient.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 13/02/2026.
//

import Foundation
import SwiftData

@Model
class UserIngredient: Hashable {
    var id = UUID()
    var name: String = ""
    var quantity: Double = 0
    var unit: String = ""
    var cocktail: UserCreatedCocktail?

    init(
        name: String,
        quantity: Double,
        unit: String
    ) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }

    var ingredient: Ingredient {
        Ingredient(name: name, quantity: quantity, unit: unit)
    }

    static func == (lhs: UserIngredient, rhs: UserIngredient) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
