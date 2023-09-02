//
//  Cocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct Cocktail: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let method: String
    let glass: String
    let garnish: String
    let ice: String
    let extra: String
    var history: String
    var pic: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/\(id)-img.jpg"
    }
    let ingredients: [Ingredient]

    var image: String {
        glass + ""
    }

    struct Ingredient: Codable, Equatable, Identifiable {
        var id: String { name }
        let name: String
        let quantity: Double
        let unit: String

        var mlQuantity: Double {
            if unit == "oz." {
                if quantity == 1.75 { return 50.0 }
                if quantity == 1.25 { return 40.0 }
                if quantity == 0.75 { return 25.0 }
                if quantity == 0.15 { return 5.00 }

                return quantity * 30.0
            }
            return quantity
        }

        var mlUnit: String {
            unit == "oz." ? "ml" : unit
        }
    }

    #if DEBUG
    static let example = Cocktail(
        id: "american",
        name: "Corpse Reviver No.2",
        method: "shake & fine strain",
        glass: "coffee mug",
        garnish: "-",
        ice: "-",
        extra: "absinthe-rinsed coupe",
//        history: "",
        history: "TEST: As with many classic cocktails, the origin story of the Manhattan is shrouded in mystery. The most popular theory suggests that the recipe was invented by Dr. Iain Marshall in the early 1880s for a party hosted by Lady Randolph Churchill, the mother of Winston Churchill, at the Manhattan Club in New York. However, this theory has been debunked because Lady Randolph Churchill was pregnant and in England at the time. A more plausible story comes from the 1923 book \"Valentine's Manual of New York\", which recounts that William F. Mulhall, a bartender at New York's Hoffman House in the 1880s, claimed the Manhattan cocktail was invented by a man named Black who owned a place ten doors below Houston Street on Broadway.",
        ingredients: [
            Ingredient(
                name: "london dry gin",
                quantity: 2.0,
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
