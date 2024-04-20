//
//  Item.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//
//

import Foundation
import SwiftData

@Model 
class Item {
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
