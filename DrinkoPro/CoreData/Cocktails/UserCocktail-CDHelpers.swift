//
//  UserCocktail-CDHelpers.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/01/2024.
//

import Foundation

extension UserCocktail {
    var userCocktailName: String {
        name ?? "Cocktail Name"
    }
    
    var userCocktailMethod: String {
        method ?? "Shake & Strain"
    }
    
    var userCocktailGlass: String {
        glass ?? "Rock"
    }
    
    var userCocktailGarnish: String {
        garnish ?? "-"
    }

    var userCocktailIce: String {
        ice ?? "Cubed"
    }

    var userCocktailExtra: String {
        extra ?? "-"
    }

    var userCocktailCreationDate: Date {
        creationDate ?? Date()
    }
    
    var userCocktailIngredients: [UserIngredient] {
        userIngredients?.allObjects as? [UserIngredient] ?? []
    }
        
    static var example: UserCocktail {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let userCocktail = UserCocktail(context: viewContext)
        userCocktail.name = "User Cocktail Name"
        userCocktail.method = "Shake & Strain"
        userCocktail.glass = "Hiball"
        userCocktail.garnish = "-"
        userCocktail.ice = "Cubed"
        userCocktail.extra = "-"
        userCocktail.creationDate = Date()
        
        return userCocktail
    }
}
