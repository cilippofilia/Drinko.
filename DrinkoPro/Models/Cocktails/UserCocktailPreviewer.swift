//
//  UserCocktailPreviewer.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 13/02/2026.
//

import Foundation
import SwiftData

@MainActor
struct UserCocktailPreviewer {
    let container: ModelContainer

    let userCocktail: UserCreatedCocktail
    let userIngredient: UserIngredient
    let userProcedure: UserProcedure
    let userProcedureStep: UserProcedureStep

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: UserCreatedCocktail.self,
            UserIngredient.self,
            UserProcedure.self,
            UserProcedureStep.self,
            configurations: config
        )
        let ingr = UserIngredient(name: "Rum", quantity: 2.0, unit: "oz.")
        let step1 = UserProcedureStep(text: "Do nothing, shake", order: 1)
        let step2 = UserProcedureStep(text: "then do something", order: 2)
        let step3 = UserProcedureStep(text: "Still continue to do nothing", order: 3)
        let procedure = UserProcedure(steps: [step1, step2, step3])
        let cocktail = UserCreatedCocktail(
            id: "user-created",
            name: "Aperum",
            method: "shake",
            glass: "rock",
            garnish: "No",
            ice: "Cubed",
            extra: "-",
            ingredients: [ingr],
            procedure: procedure,
            creationDate: .now,
            lastUpdated: .now
        )
        userCocktail = cocktail
        userIngredient = ingr
        userProcedure = procedure
        userProcedureStep = step1

        container.mainContext.insert(userCocktail)
    }
}
