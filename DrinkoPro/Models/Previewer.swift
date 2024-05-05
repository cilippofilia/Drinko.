//
//  Previewer.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    
    let category: Category
    let product: Item
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Category.self, configurations: config)

        category = Category(name: "Vodka", detail: "Taste like water", color: "Dr. Blue", creationDate: Date.now)
        product = Item(name: "Absolut", detail: "Made from potatoes", madeIn: "Poland", abv: "40")
        
        container.mainContext.insert(category)
    }
}

