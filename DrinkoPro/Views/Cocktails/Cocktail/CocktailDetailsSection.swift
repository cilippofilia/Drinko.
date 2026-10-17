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
        // The ingredients and the details are separate groups, so they get the wider group gap.
        VStack(alignment: .leading, spacing: detailCardInset) {
            IngredientsView(
                ingredients: cocktail.ingredients,
                selectedUnit: selectedUnit,
                showsOriginalUnits: showsOriginalUnits
            )

            VStack(alignment: .leading, spacing: detailCardRowSpacing) {
                CocktailDetailSectionView(cocktail: cocktail, kind: .method)
                CocktailDetailSectionView(cocktail: cocktail, kind: .glass)
                CocktailDetailSectionView(cocktail: cocktail, kind: .garnish)
                CocktailDetailSectionView(cocktail: cocktail, kind: .ice)
                CocktailDetailSectionView(cocktail: cocktail, kind: .extra)
            }
        }
    }
}

#if DEBUG && !APPCLIP
#Preview {
    CocktailDetailsSection(cocktail: .example, selectedUnit: "ml", showsOriginalUnits: false)
}
#endif
