//
//  CabinetDiscovery.swift
//  DrinkoPro
//

import Foundation

/// Sorts cocktails into what the cabinet makes now and what it makes with one base-spirit swap.
nonisolated enum CabinetDiscovery {
    static func discover(
        in cocktails: [Cocktail], stock: CabinetStock
    ) -> (makeNow: [DiscoveryMatch], twists: [DiscoveryMatch]) {
        var makeNow: [DiscoveryMatch] = []
        var twists: [DiscoveryMatch] = []
        for cocktail in cocktails {
            let bottles = cocktail.ingredients.map { ingredient in
                RecipeBottle.alternatives(in: ingredient.name).map { RecipeBottle(name: $0) }
            }
            // A drink made only of pantry staples is not a cabinet suggestion.
            guard bottles.contains(where: { options in options.contains { $0 != .staple } }) else { continue }

            let uncovered = cocktail.ingredients.indices.filter { !stock.covers(cocktail.ingredients[$0].name) }
            if uncovered.isEmpty {
                makeNow.append(DiscoveryMatch(cocktail: cocktail, swap: nil))
            } else if let index = uncovered.first, uncovered.count == 1 {
                let others = bottles.enumerated().filter { $0.offset != index }.map(\.element)
                if let swap = swap(missing: bottles[index], others: others, stock: stock) {
                    twists.append(DiscoveryMatch(cocktail: cocktail, swap: swap))
                }
            }
        }
        let byName: (DiscoveryMatch, DiscoveryMatch) -> Bool = {
            $0.cocktail.name.localizedStandardCompare($1.cocktail.name) == .orderedAscending
        }
        return (makeNow.sorted(by: byName), twists.sorted(by: byName))
    }

    /// The swap for an uncovered base spirit, or nil when no stocked substitute is free to use.
    private static func swap(missing: [RecipeBottle], others: [[RecipeBottle]], stock: CabinetStock) -> SpiritSwap? {
        guard let spirit = missing.compactMap(\.spirit).first else { return nil }
        let inDrink = Set(others.flatMap { $0.compactMap(\.spirit) })
        let substitutes = SpiritSwap.substitutes(for: spirit).filter {
            stock.spirits.contains($0) && !inDrink.contains($0)
        }
        return substitutes.isEmpty ? nil : SpiritSwap(missing: spirit, substitutes: substitutes)
    }
}

private extension RecipeBottle {
    var spirit: MainSpirit? {
        if case .spirit(let spirit) = self { spirit } else { nil }
    }
}
