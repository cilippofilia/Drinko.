//
//  Cocktail.swift
//  Drinko
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct Category: Codable, Equatable, Identifiable {
    var id: String
    let name: String
    let cocktails: [Cocktail]
}

struct Cocktail: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let garnish: String
    let ice: String
    let extra: String
    let ingredients: [Ingredient]

    var image: String {
        glass + ""
    }

    struct Ingredient: Codable, Equatable, Identifiable {
        var id: String {
            name
        }
        let name: String
        let quantity: Double
        let unit: String
    }

    #if DEBUG
    static let example = Cocktail(
        id: "corpse-reviver-2",
        name: "Corpse Reviver No.2",
        method: "shake & fine strain",
        glass: "coffee mug",
        garnish: "-",
        ice: "-",
        extra: "absinthe-rinsed coupe",
        ingredients: [
            Ingredient(
                name: "london dry gin",
                quantity: 1.75,
                unit: "oz."),
            Ingredient(
                name: "cointreau",
                quantity: 0.5,
                unit: "oz."),
            Ingredient(
                name: "dry vermouth",
                quantity: 6,
                unit: "leaves"),
            Ingredient(
                name: "angostura bitters",
                quantity: 4,
                unit: "dashes")
        ])
    #endif
}
