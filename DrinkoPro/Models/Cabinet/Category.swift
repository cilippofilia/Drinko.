//
//  Category.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//
//

import Foundation
import SwiftData

@Model 
class Category: Hashable {
    var id = UUID()
    var name: String = "Category Name"
    var detail: String = ""
    var color: String = "Dr. Blue"
    var creationDate: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var products: [Item]? = []

    private static let allColors = [
        "Dr. Indigo",
        "Dr. Magenta",
        "Dr. Purple",
        "Dr. Bubblegum",
        "Dr. Poppy",
        "Dr. Red",
        "Dr. Orange",
        "Dr. Gold",
        "Dr. Green",
        "Dr. Teal",
        "Dr. Sky",
        "Dr. Blue",
        "Dr. Dark Blue",
        "Dr. Midnight",
        "Dr. Dark Gray",
        "Dr. Gray",
        "Dr. Lavender",
        "Dr. Periwinkle",
    ]

    static let colors = allColors.filter { color in
        #if os(macOS)
        return color != "Dr. Indigo"
        #else
        return true
        #endif
    }

    init(
        name: String,
        detail: String = "",
        color: String = "Dr. Blue",
        creationDate: Date
    ) {
        self.name = name
        self.detail = detail
        self.color = color
        self.creationDate = creationDate
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Category {
    static var suggestedCategories: [Category] {
        [
            Category(
                name: "Vodkas",
                color: "Dr. Magenta", 
                creationDate: Date()
            ),
            Category(
                name: "Gins",
                color: "Dr. Lavender",
                creationDate: Date()
            ),
            Category(
                name: "Whiskeys",
                color: "Dr. Gold",
                creationDate: Date()
            ),
            Category(
                name: "Rums",
                color: "Dr. Poppy",
                creationDate: Date()
            ),
            Category(
                name: "Tequilas & Mezcals",
                color: "Dr. Green",
                creationDate: Date()
            ),
            Category(
                name: "Cognacs",
                color: "Dr. Orange",
                creationDate: Date()
            ),
            Category(
                name: "Liqueurs",
                color: "Dr. Sky",
                creationDate: Date()
            ),
            Category(
                name: "Juices",
                color: "Dr. Bubblegum",
                creationDate: Date()
            ),
            Category(
                name: "Syrups",
                color: "Dr. Red",
                creationDate: Date()
            )
        ]
    }
}

extension Category {
    static let mockCategories: [Category] = {
        let vodka = Category(
            name: "Vodka",
            detail: "Clear distilled spirits from various grains",
            color: "Dr. Sky",
            creationDate: Date()
        )
        vodka.products = [
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
            )
        ]
        vodka.products?.forEach { $0.category = vodka }

        let whiskey = Category(
            name: "Whiskey",
            detail: "Aged spirits from malted grain",
            color: "Dr. Gold",
            creationDate: Date()
        )
        whiskey.products = [
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
            Item(
                name: "Lagavulin 16",
                detail: "Islay single malt, heavily peated",
                madeIn: "Scotland",
                abv: "43",
                rating: 5,
                tried: false,
                isFavorite: true
            )
        ]
        whiskey.products?.forEach { $0.category = whiskey }

        let rum = Category(
            name: "Rum",
            detail: "Distilled from sugarcane or molasses",
            color: "Dr. Orange",
            creationDate: Date()
        )
        rum.products = [
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
            Item(
                name: "Mount Gay XO",
                detail: "Aged Barbadian rum",
                madeIn: "Barbados",
                abv: "43",
                rating: 4,
                tried: true,
                isFavorite: false
            )
        ]
        rum.products?.forEach { $0.category = rum }

        let gin = Category(
            name: "Gin",
            detail: "Juniper-flavored spirits with botanicals",
            color: "Dr. Teal",
            creationDate: Date()
        )
        gin.products = [
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
            Item(
                name: "Monkey 47",
                detail: "German gin with 47 botanicals",
                madeIn: "Germany",
                abv: "47",
                rating: 5,
                tried: false,
                isFavorite: true
            )
        ]
        gin.products?.forEach { $0.category = gin }

        let tequila = Category(
            name: "Tequila",
            detail: "Agave-based spirits from Mexico",
            color: "Dr. Green",
            creationDate: Date()
        )
        tequila.products = [
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
            ),
            Item(
                name: "Casamigos Reposado",
                detail: "Rested tequila with smooth finish",
                madeIn: "Mexico",
                abv: "40",
                rating: 4,
                tried: true,
                isFavorite: false
            )
        ]
        tequila.products?.forEach { $0.category = tequila }

        let cognac = Category(
            name: "Cognac",
            detail: "French brandy from the Cognac region",
            color: "Dr. Red",
            creationDate: Date()
        )
        cognac.products = [
            Item(
                name: "Hennessy VS",
                detail: "Classic cognac with rich flavors",
                madeIn: "France",
                abv: "40",
                rating: 4,
                tried: true,
                isFavorite: false
            ),
            Item(
                name: "Rémy Martin VSOP",
                detail: "Smooth and aromatic cognac",
                madeIn: "France",
                abv: "40",
                rating: 4,
                tried: true,
                isFavorite: true
            ),
            Item(
                name: "Courvoisier XO",
                detail: "Extra old cognac, complex and refined",
                madeIn: "France",
                abv: "40",
                rating: 5,
                tried: false,
                isFavorite: true
            )
        ]
        cognac.products?.forEach { $0.category = cognac }

        let liqueur = Category(
            name: "Liqueur",
            detail: "Sweetened spirits with various flavors",
            color: "Dr. Magenta",
            creationDate: Date()
        )
        liqueur.products = [
            Item(
                name: "Cointreau",
                detail: "Orange liqueur for cocktails",
                madeIn: "France",
                abv: "40",
                rating: 4,
                tried: true,
                isFavorite: false
            ),
            Item(
                name: "Baileys",
                detail: "Irish cream liqueur",
                madeIn: "Ireland",
                abv: "17",
                rating: 4,
                tried: true,
                isFavorite: true
            ),
            Item(
                name: "Kahlúa",
                detail: "Coffee liqueur from Mexico",
                madeIn: "Mexico",
                abv: "20",
                rating: 3,
                tried: true,
                isFavorite: false
            ),
            Item(
                name: "Chambord",
                detail: "Black raspberry liqueur",
                madeIn: "France",
                abv: "16.5",
                rating: 4,
                tried: false,
                isFavorite: false
            ),
            Item(
                name: "Grand Marnier",
                detail: "Cognac-based orange liqueur",
                madeIn: "France",
                abv: "40",
                rating: 5,
                tried: false,
                isFavorite: true
            )
        ]
        liqueur.products?.forEach { $0.category = liqueur }

        return [vodka, whiskey, rum, gin, tequila, cognac, liqueur]
    }()
}
