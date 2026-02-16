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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(ingredients) { ingredient in
                HStack {
                    Text(ingredient.convertedQuantity(to: selectedUnit), format: .number.precision(.fractionLength(0...2)))

                    Text(ingredient.convertedUnit(to: selectedUnit))

                    Text(ingredient.name.capitalized)

                    Spacer()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ingredient.name.capitalized)
                .accessibilityValue("\(ingredient.convertedQuantity(to: selectedUnit), specifier: "%2g") \(ingredient.convertedUnit(to: selectedUnit))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom)
    }
}

#if DEBUG
#Preview {
    IngredientsView(ingredients: [], selectedUnit: "ml")
}
#endif
