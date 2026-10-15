//
//  UserCocktailFormState.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/10/2026.
//

import Foundation

/// The starting values for the user cocktail form, either blank or copied
/// from the cocktail being edited.
struct UserCocktailFormState {
    var name: String
    var method: String
    var glass: String
    var garnish: String
    var ice: String
    var extra: String
    var ingredientDrafts: [IngredientDraft]
    var procedureDrafts: [String]
}
