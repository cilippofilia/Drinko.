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
    
    let ingredients: [Ingredient]
    
    var pic: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-cocktail-pics/main/\(id)-img.jpg"
    }

    var image: String {
        glass
    }
    
    enum SortOption {
        case fromAtoZ
        case fromZtoA
        case byGlass
        case byIce
    }

    #if DEBUG
    static let example = Cocktail(
        id: "margarita",
        name: "Corpse Reviver No.2",
        method: "shake & fine strain",
        glass: "shot",
        garnish: "-",
        ice: "-",
        extra: "absinthe-rinsed coupe",
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
        ]
    )
    #endif
}

extension Cocktail {
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
}

struct History: Codable, Equatable, Identifiable {
    let id: String
    let text: String
    
    #if DEBUG
    static let example = History(id: "cosmopolitan",
                                 text: "Bartending legend Dale \"King Cocktail\" DeGroff discovered the Cosmopolitan at the Fog City Diner in San Francisco in the mid-1990s. He then perfected his own recipe for the cocktail, including his signature flamed orange zest twist as a garnish, while working at the Rainbow Rooms in Manhattan.\n\nDeGroff has never claimed to have invented the Cosmopolitan. In his 2002 book \"The Craft of Cocktail\", he explains that he popularized a definitive recipe that became widely accepted as the standard.\n\nThe Cosmopolitan gained immense popularity after it was frequently shown on the television show \"Sex and the City\", with the characters often sipping Cosmos and wondering why they ever stopped drinking them. The show's influence helped the cocktail become a household name.")
    #endif
}


struct Procedure: Codable, Equatable, Identifiable {
    let id: String
    let procedure: [Steps]
    
    struct Steps: Codable, Equatable, Identifiable {
        var id: String { text }
        let step: String
        let text: String
    }
    
    #if DEBUG
    static let example = Procedure(id: "cosmopolitan",
                                   procedure: [
                                    Procedure.Steps(step: "Step 1",
                                                    text: "Add all the ingredients into the cocktail shaker; a part from the red wine"),
                                    Procedure.Steps(step: "Step 2",
                                                    text: "Shake hard to emulsify your foaming agent. Add fresh cubed ice to the shaker, lock it, and shake hard for 8 to 12 seconds (until it is frosty outside)"),
                                    Procedure.Steps(step: "Step 3",
                                                    text: "Add cubed ice to the glass, fine strain the cocktail inside the glass and allow it to settle"),
                                    Procedure.Steps(step: "Step 4",
                                                    text: "Use a barspoon to float the red wine and enjoy!")
                                   ])
    #endif
}
