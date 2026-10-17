//
//  ABVCalculatorViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

@MainActor
@Observable
final class ABVCalculatorViewModel {
    var bottles: [Bottle] = [Bottle()]
    var method: MixingMethod = .built
    var serving: Serving = .up

    /// The last ingredient can never be removed.
    var canRemoveIngredients: Bool {
        bottles.count > 1
    }

    /// The water mixing adds, as a fraction of the drink's volume.
    var dilutionFactor: Double {
        switch (serving, method) {
        case (.up, .stir):
            0.25
        case (.up, .shake):
            0.3
        case (.rocks, .stir):
            0.3
        case (.rocks, .shake):
            0.35
        case (.crushed, .shake):
            0.4
        default:
            0.0
        }
    }

    /// A percentage, so `12.5` means 12.5%.
    var result: Double {
        let totalVolume = bottles.reduce(0) { $0 + $1.amount }
        guard totalVolume > 0 else { return 0 }

        let totalAlcohol = bottles.reduce(0) { $0 + ($1.amount * $1.abv / 100) }
        let dilutedVolume = totalVolume * (1 + dilutionFactor)
        guard dilutedVolume > 0 else { return 0 }

        return totalAlcohol / dilutedVolume * 100
    }

    func addIngredient() {
        bottles.append(Bottle())
    }

    func removeIngredient(id: Bottle.ID) {
        guard canRemoveIngredients else { return }
        bottles.removeAll { $0.id == id }
    }

    /// 1-based, for accessibility values.
    func ingredientNumber(for id: Bottle.ID) -> Int {
        (bottles.firstIndex { $0.id == id } ?? 0) + 1
    }
}
