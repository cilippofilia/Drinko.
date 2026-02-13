//
//  UserProcedure.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 13/02/2026.
//

import Foundation
import SwiftData
@Model
class UserProcedure: Hashable {
    var id = UUID()
    @Relationship(deleteRule: .cascade, inverse: \UserProcedureStep.procedure)
    var steps: [UserProcedureStep]?
    var cocktail: UserCreatedCocktail?

    init(steps: [UserProcedureStep] = []) {
        self.steps = steps
    }

    static func == (lhs: UserProcedure, rhs: UserProcedure) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class UserProcedureStep: Hashable {
    var id = UUID()
    var text: String = ""
    var order: Int = 0
    var procedure: UserProcedure?

    init(text: String, order: Int) {
        self.text = text
        self.order = order
    }

    static func == (lhs: UserProcedureStep, rhs: UserProcedureStep) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
