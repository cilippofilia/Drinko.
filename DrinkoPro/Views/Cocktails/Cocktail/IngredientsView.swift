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
                    Text(selectedUnit == "oz." ? "\(ingredient.quantity, specifier: "%2g")" : "\(ingredient.mlQuantity, specifier: "%2g")")

                    Text(selectedUnit == "oz." ? ingredient.unit : ingredient.mlUnit)

                    Text(ingredient.name.capitalized)

                    Spacer()
                }
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
