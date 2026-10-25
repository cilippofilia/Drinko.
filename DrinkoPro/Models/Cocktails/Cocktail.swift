//
//  Cocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

nonisolated struct Cocktail: Codable, Equatable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let garnish: String
    let ice: String
    let extra: String
    
    let ingredients: [Ingredient]

    var pic: String {
        if id == "augie-march" {
            "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/manhattan-img.jpg"
        } else {
            "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/\(id)-img.jpg"
        }
    }

    /// `nil` for the user's own cocktails.
    var stickerURL: URL? {
        guard !isUserCreated else { return nil }
        let name = Self.stickerNames[id] ?? id
        return URL(string: "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main/drinko-\(name).png")
    }

    var image: String {
        glass
    }

    /// The glass artwork shown for a cocktail without a sticker or photo, like the user's own.
    var glassArtwork: LibraryImage {
        switch glass {
        case "wine":
            .symbol("wineglass")
        case "coffee mug", "julep cup":
            .asset("julep")
        case "highball":
            // There is no highball artwork; the collins glass is the closest match.
            .asset("collins")
        default:
            .asset(image)
        }
    }

    var isUserCreated: Bool {
        id.hasPrefix("user-")
    }

    func matches(_ query: String) -> Bool {
        name.localizedStandardContains(query)
            || ingredients.contains { $0.name.localizedStandardContains(query) }
    }

    /// Drinks whose sticker is filed under another name.
    private static let stickerNames = [
        "augie-march": "manhattan",
        "gin-martini": "dry-martini"
    ]
}

enum SortOption: CaseIterable {
    case fromAtoZ
    case fromZtoA
    case byGlass
    case byIce

    var title: LocalizedStringKey {
        switch self {
        case .fromAtoZ:
            "A > Z"
        case .fromZtoA:
            "Z > A"
        case .byGlass:
            "By Glass"
        case .byIce:
            "By Ice"
        }
    }
}

nonisolated struct Ingredient: Codable, Equatable, Identifiable, Hashable, Sendable {
    var id: String { name }
    let name: String
    let quantity: Double
    let unit: String

    @MainActor
    var mlQuantity: Double {
        if unit == "oz." {
            return UnitConverter.convert(quantity, from: "oz.", to: "ml")
        }
        return quantity
    }

    @MainActor
    func convertedQuantity(to targetUnit: String) -> Double {
        UnitConverter.convert(quantity, from: unit, to: targetUnit)
    }

    @MainActor
    func convertedUnit(to targetUnit: String) -> String {
        UnitConverter.unitLabel(for: unit, convertingTo: targetUnit)
    }
}

nonisolated struct History: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let text: String    
}

nonisolated struct Procedure: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let procedure: [Steps]
    
    struct Steps: Codable, Equatable, Identifiable, Sendable {
        var id: String { "\(step)-\(text)" }
        let step: String
        let text: String
    }
}

public struct IngredientDraft {
    var name = ""
    var quantity = ""
    var unit: String
}

extension MainSpirit {
    @MainActor
    init?(ingredients: [Ingredient]) {
        self.init(pours: ingredients.map { (name: $0.name, milliliters: $0.mlQuantity) })
    }
}
