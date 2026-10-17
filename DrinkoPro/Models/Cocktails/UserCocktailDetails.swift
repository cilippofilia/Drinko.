//
//  UserCocktailDetails.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/10/2026.
//

import Foundation

/// The values needed to create or update a user-created cocktail.
struct UserCocktailDetails {
    /// What to do with the cocktail's photo or sticker when saving.
    enum PhotoChange: Equatable {
        /// Keep whatever is stored, without re-encoding it.
        case unchanged
        /// Store this already-processed image data.
        case set(Data)
        case remove

        /// What saving should do to go from the `original` draft to the `current` one: nothing
        /// if it's untouched, so it isn't re-encoded.
        static func between(_ original: Data?, _ current: Data?) -> PhotoChange {
            guard current != original else { return .unchanged }
            return current.map { .set($0) } ?? .remove
        }
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
    var stickerChange: PhotoChange = .unchanged
    var tintColor: String?
}
