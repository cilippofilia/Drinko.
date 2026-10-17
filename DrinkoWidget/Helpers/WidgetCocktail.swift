//
//  WidgetCocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI

// The subset of the cocktail JSON the widget needs, so it doesn't pull in the app's model.
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

    /// Tints the sticker's backdrop. `nil` for drinks without one, such as wine-based ones.
    var mainSpirit: MainSpirit? {
        MainSpirit(pours: ingredients.map { (name: $0.name, milliliters: $0.milliliters) })
    }

    /// Every bundled shot is served in a shot glass.
    var isShot: Bool {
        glass == "shot"
    }

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
