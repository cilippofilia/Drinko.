//
//  ABVIngredientRow.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import SwiftUI

/// A single ingredient row for the ABV calculator: its name, amount and alcohol by volume.
struct ABVIngredientRow: View {
    @Binding var bottle: Bottle
    var isFocused: FocusState<Bool>.Binding
    let ingredientNumber: Int
    let canRemove: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack {
            HStack {
                TextField("What is the ingredient?", text: $bottle.name)
                    .accessibilityLabel("Ingredient name")
                    .accessibilityValue("Ingredient \(ingredientNumber)")
                    #if os(iOS)
                    .keyboardType(.default)
                    .focused(isFocused)
                    #endif

                if canRemove {
                    Button("Delete", systemImage: "xmark.circle", action: onDelete)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .accessibilityLabel("Delete ingredient")
                        .accessibilityValue("Ingredient \(ingredientNumber)")
                }
            }

            HStack {
                HStack {
                    TextField("Amount?", value: $bottle.amount, format: .number)
                        .accessibilityLabel("Amount in millilitres")
                        .accessibilityValue("Ingredient \(ingredientNumber)")
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        .focused(isFocused)
                        #endif

                    Text("ml")
                        .accessibilityHidden(true)
                }

                HStack {
                    TextField("ABV?", value: $bottle.abv, format: .number)
                        .accessibilityLabel("Alcohol by volume percentage")
                        .accessibilityValue("Ingredient \(ingredientNumber)")
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        .focused(isFocused)
                        #endif

                    Text("%")
                        .accessibilityHidden(true)
                }
            }

            Divider()
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    @Previewable @FocusState var isFocused: Bool
    @Previewable @State var bottle = Bottle()

    ABVIngredientRow(
        bottle: $bottle,
        isFocused: $isFocused,
        ingredientNumber: 1,
        canRemove: true,
        onDelete: {}
    )
}
#endif
