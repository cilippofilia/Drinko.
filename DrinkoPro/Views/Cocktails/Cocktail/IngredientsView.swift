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
                let quantity = showsOriginalUnits
                    ? ingredient.quantity
                    : ingredient.convertedQuantity(to: selectedUnit)
                let unit = showsOriginalUnits
                    ? ingredient.unit
                    : ingredient.convertedUnit(to: selectedUnit)

                HStack {
                    Text(quantity, format: .number.precision(.fractionLength(0...2)))

                    Text(unit)

                    Text(ingredient.name.capitalized)

                    Spacer()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ingredient.name.capitalized)
                .accessibilityValue("\(quantity, specifier: "%2g") \(unit)")
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
