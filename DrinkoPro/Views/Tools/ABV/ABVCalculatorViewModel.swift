//
//  ABVCalculatorViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

/// Drives the ABV calculator: holds the ingredients, the chosen mixing method and serving,
/// and exposes the resulting alcohol-by-volume percentage live as those inputs change.
@MainActor
@Observable
final class ABVCalculatorViewModel {
    var bottles: [Bottle] = [Bottle()]
    var method: MixingMethod = .built
    var serving: Serving = .up

    /// Whether there is more than one ingredient, so the last one can never be removed.
    var canRemoveIngredients: Bool {
        bottles.count > 1
    }

    /// The dilution added by the chosen serving and mixing method combination.
    ///
    /// Built in the glass and served up adds no dilution, since there is no extra water from
    /// shaking, stirring or ice. Every other combination dilutes the drink by a fixed amount:
    /// - Up + Stirred: 25%
    /// - Up + Shaken: 30%
    /// - On the rocks + Stirred: 30%
    /// - On the rocks + Shaken: 35%
    /// - Crushed Ice + Shaken: 40%
    /// - Everything else: no additional dilution
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

    /// The overall ABV of the batch, as a percentage (for example `12.5` means 12.5%).
    ///
    /// Returns `0` when the total volume is zero, rather than dividing by zero.
    var result: Double {
        let totalVolume = bottles.reduce(0) { $0 + $1.amount }
        guard totalVolume > 0 else { return 0 }

        let totalAlcohol = bottles.reduce(0) { $0 + ($1.amount * $1.abv / 100) }
        let dilutedVolume = totalVolume * (1 + dilutionFactor)
        guard dilutedVolume > 0 else { return 0 }

        return totalAlcohol / dilutedVolume * 100
    }

    /// Adds a new, empty ingredient row.
    func addIngredient() {
        bottles.append(Bottle())
    }

    /// Removes the ingredient with the given id, unless it is the only one left.
    func removeIngredient(id: Bottle.ID) {
        guard canRemoveIngredients else { return }
        bottles.removeAll { $0.id == id }
    }

    /// The 1-based position of the ingredient with the given id, for accessibility values.
    func ingredientNumber(for id: Bottle.ID) -> Int {
        (bottles.firstIndex { $0.id == id } ?? 0) + 1
    }
}
