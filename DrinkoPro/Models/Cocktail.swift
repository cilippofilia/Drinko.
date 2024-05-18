//
//  Cocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct Cocktail: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let garnish: String
    let ice: String
    let extra: String
    
    let ingredients: [Ingredient]
    
    var pic: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/\(id)-img.jpg"
    }

    var image: String {
        glass
    }
}

enum SortOption {
    case fromAtoZ
    case fromZtoA
    case byGlass
    case byIce
}

struct Ingredient: Codable, Equatable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let quantity: Double
    let unit: String

    var mlQuantity: Double {
        if unit == "oz." {
            if quantity == 1.75 { return 50.0 }
            if quantity == 1.25 { return 40.0 }
            if quantity == 0.75 { return 25.0 }
            if quantity == 0.66 { return 20.0 }
            if quantity == 0.33 { return 10.0 }
            if quantity == 0.15 { return 5.00 }

            return quantity * 30.0
        }
        return quantity
    }

    var mlUnit: String {
        unit == "oz." ? "ml" : unit
    }
}

struct History: Codable, Equatable, Identifiable {
    let id: String
    let text: String    
}

struct Procedure: Codable, Equatable, Identifiable {
    let id: String
    let procedure: [Steps]
    
    struct Steps: Codable, Equatable, Identifiable {
        var id: String { text }
        let step: String
        let text: String
    }
}
