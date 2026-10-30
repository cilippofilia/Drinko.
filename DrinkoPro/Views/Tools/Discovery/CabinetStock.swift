//
//  CabinetStock.swift
//  DrinkoPro
//

import Foundation

/// The user's Cabinet bottles, reduced to what a recipe ingredient can be checked against.
nonisolated struct CabinetStock: Sendable {
    let spirits: Set<MainSpirit>
    private let styles: Set<BottleStyle>
    /// Folded "name category" of every bottle, for ingredients the app can't classify.
    private let names: [String]

    init(bottles: [(name: String, category: String?)]) {
        var spirits: Set<MainSpirit> = []
        var styles: Set<BottleStyle> = []
        var names: [String] = []
        for bottle in bottles {
            let text = "\(bottle.name) \(bottle.category ?? "")"
            // Cabinet side only: "Gins" should resolve to gin, so also try each word without a trailing "s".
            let singular = text.split(separator: " ")
                .map { $0.hasSuffix("s") || $0.hasSuffix("S") ? String($0.dropLast()) : String($0) }
                .joined(separator: " ")
            for variant in [text, singular] {
                if let spirit = MainSpirit(ingredientName: variant), spirit.isBaseSpirit {
                    spirits.insert(spirit)
                }
                if let style = BottleStyle(name: variant) {
                    styles.insert(style)
                }
            }
            names.append(RecipeBottle.fold(text))
        }
        self.spirits = spirits
        self.styles = styles
        self.names = names
    }

    /// Whether any alternative of the ingredient is a staple, a stocked spirit or style, or a stocked bottle name.
    func covers(_ ingredientName: String) -> Bool {
        RecipeBottle.alternatives(in: ingredientName).contains { alternative in
            switch RecipeBottle(name: alternative) {
            case .staple: true
            case .spirit(let spirit): spirits.contains(spirit)
            case .style(let style): styles.contains(style)
            case .other(let name): !name.isEmpty && names.contains { $0.contains(name) }
            }
        }
    }
}
