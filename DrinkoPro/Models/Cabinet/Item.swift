//
//  Item.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//
//

import SwiftData
import SwiftUI

@Model 
class Item: Hashable {
    var id = UUID()
    var name: String = "Product Name"
    var detail: String = ""
    var madeIn: String = "Italy"
    var abv: String = "43"
    var rating: Int = 3
    var tried: Bool = false
    var creationDate: Date = Date()
    var isFavorite: Bool = false
    
    var category: Category?
    
    init(
        name: String,
        detail: String = "",
        madeIn: String = "",
        abv: String = "",
        rating: Int = 3,
        tried: Bool = false,
        creationDate: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.name = name
        self.detail = detail
        self.madeIn = madeIn
        self.abv = abv
        self.rating = rating
        self.tried = tried
        self.creationDate = creationDate
        self.isFavorite = isFavorite
    }
}


extension Item {
    static let mockItems: [Item] = [
        // Vodka items
        Item(
            name: "Grey Goose",
            detail: "Premium French vodka with a smooth, clean taste",
            madeIn: "France",
            abv: "40",
            rating: 5,
            tried: true,
            isFavorite: true
        ),
        Item(
            name: "Belvedere",
            detail: "Polish rye vodka, quadruple distilled",
            madeIn: "Poland",
            abv: "40",
            rating: 4,
            tried: true,
            isFavorite: false
        ),
        Item(
            name: "Tito's",
            detail: "American craft vodka, gluten-free",
            madeIn: "USA",
            abv: "40",
            rating: 4,
            tried: true,
            isFavorite: true
        ),
        Item(
            name: "Absolut",
            detail: "Swedish vodka with various flavors",
            madeIn: "Sweden",
            abv: "40",
            rating: 3,
            tried: false,
            isFavorite: false
        ),

        // Whiskey items
        Item(
            name: "Jameson",
            detail: "Irish whiskey, triple distilled",
            madeIn: "Ireland",
            abv: "40",
            rating: 4,
            tried: true,
            isFavorite: true
        ),
        Item(
            name: "Jack Daniel's",
            detail: "Tennessee whiskey, charcoal mellowed",
            madeIn: "USA",
            abv: "40",
            rating: 4,
            tried: true,
            isFavorite: false
        ),
        Item(
            name: "Glenfiddich 12",
            detail: "Single malt Scotch whisky",
            madeIn: "Scotland",
            abv: "40",
            rating: 5,
            tried: false,
            isFavorite: false
        ),
        Item(
            name: "Maker's Mark",
            detail: "Kentucky bourbon with red wax seal",
            madeIn: "USA",
            abv: "45",
            rating: 4,
            tried: true,
            isFavorite: true
        ),

        // Rum items
        Item(
            name: "Bacardi",
            detail: "White rum, light and mixable",
            madeIn: "Puerto Rico",
            abv: "40",
            rating: 3,
            tried: true,
            isFavorite: false
        ),
        Item(
            name: "Captain Morgan",
            detail: "Spiced rum with vanilla notes",
            madeIn: "Jamaica",
            abv: "35",
            rating: 3,
            tried: true,
            isFavorite: false
        ),
        Item(
            name: "Diplomatico",
            detail: "Venezuelan dark rum, rich and sweet",
            madeIn: "Venezuela",
            abv: "40",
            rating: 5,
            tried: false,
            isFavorite: true
        ),

        // Gin items
        Item(
            name: "Tanqueray",
            detail: "London dry gin with juniper",
            madeIn: "England",
            abv: "47.3",
            rating: 4,
            tried: true,
            isFavorite: true
        ),
        Item(
            name: "Hendrick's",
            detail: "Scottish gin with cucumber and rose",
            madeIn: "Scotland",
            abv: "41.4",
            rating: 5,
            tried: true,
            isFavorite: true
        ),
        Item(
            name: "Bombay Sapphire",
            detail: "Premium gin with 10 botanicals",
            madeIn: "England",
            abv: "40",
            rating: 4,
            tried: false,
            isFavorite: false
        ),

        // Tequila items
        Item(
            name: "Patrón Silver",
            detail: "Premium tequila, smooth and refined",
            madeIn: "Mexico",
            abv: "40",
            rating: 5,
            tried: true,
            isFavorite: true
        ),
        Item(
            name: "Don Julio 1942",
            detail: "Añejo tequila, aged in oak barrels",
            madeIn: "Mexico",
            abv: "38",
            rating: 5,
            tried: false,
            isFavorite: true
        ),
        Item(
            name: "Jose Cuervo",
            detail: "Classic tequila for mixing",
            madeIn: "Mexico",
            abv: "40",
            rating: 2,
            tried: true,
            isFavorite: false
        )
    ]

    // Individual named items for quick access
    static let greyGoose = mockItems[0]
    static let jameson = mockItems[4]
    static let diplomatico = mockItems[10]
    static let hendricks = mockItems[12]
    static let patron = mockItems[14]
}
