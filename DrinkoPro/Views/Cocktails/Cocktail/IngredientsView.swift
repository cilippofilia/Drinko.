//
//  IngredientsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct IngredientsView: View {
    let ingredients: [Ingredient]
    let selectedUnit: String
    let showsOriginalUnits: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(ingredients) { ingredient in
                let line = IngredientLine(
                    ingredient: ingredient,
                    selectedUnit: selectedUnit,
                    showsOriginalUnits: showsOriginalUnits
                )

                HStack {
                    Text(line.quantity, format: .number.precision(.fractionLength(0...2)))

                    Text(line.unit)

                    Text(line.name)

                    Spacer()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(line.name)
                .accessibilityValue("\(line.quantity, specifier: "%2g") \(line.unit)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom)
    }
}

#if DEBUG
#Preview {
    IngredientsView(ingredients: [], selectedUnit: "ml", showsOriginalUnits: false)
}
#endif
