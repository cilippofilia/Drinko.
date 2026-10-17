//
//  UserCocktailColorSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/10/2026.
//

import SwiftUI

/// The Card Color section of the create/edit cocktail forms. When the ingredients have a main
/// spirit the card takes that spirit's color, shown here read-only; otherwise the person picks one.
/// Edits a draft; the form saves it.
struct UserCocktailColorSection: View {
    /// The ingredients as currently drafted, which decide the automatic color.
    let ingredients: [Ingredient]
    /// The picked color. Kept even while a spirit overrides it, so it returns if the spirit is removed.
    @Binding var tintColor: String?

    @ScaledMetric private var swatchSize: CGFloat = 24

    var body: some View {
        let spirit = MainSpirit(ingredients: ingredients)

        Section {
            if let spirit {
                HStack {
                    Color(spirit.colorName)
                        .frame(width: swatchSize, height: swatchSize)
                        .clipShape(.rect(cornerRadius: 6, style: .continuous))
                        .accessibilityHidden(true)
                    Text("Automatic, from \(spirit.displayName)")
                }
            } else {
                ColorSwatchPicker(
                    colors: Category.colors,
                    accessibilityHint: "Selects this color for the card.",
                    selection: $tintColor
                )
            }
        } header: {
            Text("Card Color")
        } footer: {
            if spirit == nil {
                Text("Pick a color for this cocktail's card.")
            } else {
                Text("Cocktails take their main ingredient's color. Pick one when they don't have one.")
            }
        }
    }
}

#Preview {
    UserCocktailColorSection(
        ingredients: [
            Ingredient(
                name: "london dry gin",
                quantity: 2.0,
                unit: "oz."),
            Ingredient(
                name: "cointreau",
                quantity: 0.5,
                unit: "oz."),
            Ingredient(
                name: "dry vermouth",
                quantity: 6,
                unit: "leaves"),
            Ingredient(
                name: "angostura bitters",
                quantity: 4,
                unit: "dashes")
        ],
        tintColor: .constant(nil)
    )
}
