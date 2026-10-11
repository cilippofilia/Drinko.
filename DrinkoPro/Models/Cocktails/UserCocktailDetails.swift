//
//  UserCocktailDetails.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/10/2026.
//

import Foundation

/// The values needed to create or update a user-created cocktail.
struct UserCocktailDetails {
    /// What to do with the cocktail's photo when saving.
    enum PhotoChange: Equatable {
        /// Keep whatever is stored, without re-encoding it.
        case unchanged
        /// Store this already-processed JPEG.
        case set(Data)
        /// Delete the stored photo.
        case remove
    }

    var name: String
    var method: String
    var glass: String
    var garnish: String
    var ice: String
    var extra: String
    var ingredients: [Ingredient]
    var procedureSteps: [String]
    var photoChange: PhotoChange = .unchanged
}
