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

    var pic: String {
        if id == "augie-march" {
            "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/manhattan-img.png"
        } else {
            "https://raw.githubusercontent.com/cilippofilia/drinko-clear-cocktail-pics/main/\(id)-img.png"
        }
    }

    var imageURL: URL? {
        URL(string: pic)
    }
}

struct WidgetIngredient: Codable, Equatable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let quantity: Double
    let unit: String
}
