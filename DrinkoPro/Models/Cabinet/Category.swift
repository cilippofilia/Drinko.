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
class Category {
    var name: String = "Category Name"
    var detail: String = ""
    var color: String = "Dr. Blue"
    var creationDate: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var products: [Item]? = []
    
    static let colors = [
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
