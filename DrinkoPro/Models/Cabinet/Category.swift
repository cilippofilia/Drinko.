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
                color: MainSpirit.vodka.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Gins",
                color: MainSpirit.gin.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Whiskeys",
                color: MainSpirit.whiskey.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Rums",
                color: MainSpirit.rum.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Tequilas & Mezcals",
                color: MainSpirit.tequila.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Cognacs",
                color: MainSpirit.cognac.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Liqueurs",
                color: MainSpirit.liqueur.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Juices",
                color: MainSpirit.juice.colorName,
                creationDate: Date()
            ),
            Category(
                name: "Syrups",
                color: MainSpirit.syrup.colorName,
                creationDate: Date()
            )
        ]
    }
}
