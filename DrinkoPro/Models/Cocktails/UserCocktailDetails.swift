//
//  UserCocktailDetails.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/10/2026.
//

import Foundation

/// The values needed to create or update a user-created cocktail.
struct UserCocktailDetails {
    var name: String
    var method: String
    var glass: String
    var garnish: String
    var ice: String
    var extra: String
    var ingredients: [Ingredient]
    var procedureSteps: [String]
}
