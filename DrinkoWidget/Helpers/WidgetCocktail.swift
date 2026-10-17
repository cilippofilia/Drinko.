//
//  WidgetCocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI

// The widget only needs a lightweight read-only model, so it decodes a small
// subset of the cocktail JSON instead of pulling in the full app view model.
struct WidgetCocktail: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let garnish: String
    let ice: String
    let extra: String

    let ingredients: [WidgetIngredient]

    /// The drink's sticker from the Drinko-stickers repo, matching the app's `Cocktail.stickerURL`.
    var stickerURL: URL? {
        let name = Self.stickerNames[id] ?? id
        return URL(string: "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main/drinko-\(name).png")
    }

    /// The family the drink is built on, whose color washes the sticker's backdrop as on the
    /// app's library cards. `nil` for drinks without one, such as wine-based ones.
    var mainSpirit: MainSpirit? {
        MainSpirit(pours: ingredients.map { (name: $0.name, milliliters: $0.milliliters) })
    }

    /// Whether this is one of the bundled shots, which are all served in a shot glass.
    var isShot: Bool {
        glass == "shot"
    }

    /// The ingredient names in pouring order, as one line the widget can wrap.
    var ingredientList: String {
        ingredients.map(\.name.capitalized).joined(separator: " · ")
    }

    /// Drinks that share another drink's sticker. Keep in sync with `Cocktail.stickerNames`.
    private static let stickerNames = [
        "augie-march": "manhattan",
        "gin-martini": "dry-martini"
    ]
}

struct WidgetIngredient: Codable, Equatable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let quantity: Double
    let unit: String

    /// The poured amount in milliliters, converting ounces the same way the app does.
    var milliliters: Double {
        unit == "oz." ? quantity * 30 : quantity
    }
}
