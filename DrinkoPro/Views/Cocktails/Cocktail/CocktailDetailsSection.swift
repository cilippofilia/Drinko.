//
//  CocktailDetailsSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

struct CocktailDetailsSection: View {
    let cocktail: Cocktail
    let selectedUnit: String
    let showsOriginalUnits: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)

            IngredientsView(
                ingredients: cocktail.ingredients,
                selectedUnit: selectedUnit,
                showsOriginalUnits: showsOriginalUnits
            )

            CocktailDetailSectionView(
                cocktail: cocktail,
                kind: .method
            )

            CocktailDetailSectionView(
                cocktail: cocktail,
                kind: .glass
            )

            CocktailDetailSectionView(
                cocktail: cocktail,
                kind: .garnish
            )

            CocktailDetailSectionView(
                cocktail: cocktail,
                kind: .ice
            )

            CocktailDetailSectionView(
                cocktail: cocktail,
                kind: .extra
            )
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview {
    CocktailDetailsSection(cocktail: .example, selectedUnit: "ml", showsOriginalUnits: false)
}
#endif
