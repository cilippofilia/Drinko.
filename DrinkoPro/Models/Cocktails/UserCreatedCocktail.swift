//
//  UserCreatedCocktail.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/02/2026.
//

import Foundation
import SwiftData

@Model
class UserCreatedCocktail {
    var id: String = ""
    var name: String = ""
    var method: String = ""
    var glass: String = ""
    var garnish: String = ""
    var ice: String = ""
    var extra: String = ""
    @Relationship(deleteRule: .cascade, inverse: \UserIngredient.cocktail)
    var ingredients: [UserIngredient]?
    @Relationship(deleteRule: .cascade, inverse: \UserProcedure.cocktail)
    var procedure: UserProcedure?
    var creationDate: Date = Date()
    var lastUpdated: Date?

    init(
        id: String? = nil,
        name: String,
        method: String,
        glass: String,
        garnish: String,
        ice: String,
        extra: String,
        ingredients: [UserIngredient] = [],
        procedure: UserProcedure? = nil,
        creationDate: Date = Date(),
        lastUpdated: Date? = nil
    ) {
        self.id = id ?? Self.makeUserCocktailID(from: name)
        self.name = name
        self.method = method
        self.glass = glass
        self.garnish = garnish
        self.ice = ice
        self.extra = extra
        self.ingredients = ingredients
        self.procedure = procedure
        self.creationDate = creationDate
        self.lastUpdated = lastUpdated
    }
}

extension UserCreatedCocktail {
    var cocktail: Cocktail {
        Cocktail(
            id: id,
            name: name,
            method: method,
            glass: glass,
            garnish: garnish,
            ice: ice,
            extra: extra,
            ingredients: (ingredients ?? []).map { $0.ingredient }
        )
    }

    var mappedProcedure: UserProcedure? {
        procedure.map({ UserProcedure(steps: $0.steps ?? []) })
    }

    static func makeUserCocktailID(from name: String) -> String {
        let normalizedName = name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        let fallback = normalizedName.isEmpty ? "user-cocktail" : normalizedName
        return "user-\(fallback)-\(UUID().uuidString.prefix(6).lowercased())"
    }
}
