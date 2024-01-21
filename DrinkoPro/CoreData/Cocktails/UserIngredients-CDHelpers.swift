//
//  UserIngredients-CDHelpers.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/01/2024.
//

import Foundation

extension UserIngredient {
    enum SortOrder {
        case quantity, name, creationDate
    }

    var userIngredientName: String {
        name ?? "Insert Ingredient Name"
    }
        
    var userIngredientUnit: String {
        unit ?? "ml"
    }
    
    var userIngredientCreationDate: Date {
        creationDate ?? Date()
    }
    
    var userCreatedIngredient: Cocktail.Ingredient {
        return Cocktail.Ingredient(name: userIngredientName, quantity: quantity, unit: userIngredientUnit)
    }
    
    static var example: UserIngredient {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let ingredient = UserIngredient(context: viewContext)
        ingredient.name = "Example ingredient"
        ingredient.unit = "ml"
        ingredient.quantity = 25.0
        ingredient.creationDate = Date()
        
        return ingredient
    }
}
