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
    
    @Relationship(.unique)
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
        detail: String,
        color: String,
        creationDate: Date
    ) {
        self.name = name
        self.detail = detail
        self.color = color
        self.creationDate = creationDate
    }
}
