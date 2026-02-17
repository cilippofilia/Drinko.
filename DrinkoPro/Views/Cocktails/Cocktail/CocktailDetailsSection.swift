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
            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Ingredients"
            )
            
            IngredientsView(
                ingredients: cocktail.ingredients,
                selectedUnit: selectedUnit,
                showsOriginalUnits: showsOriginalUnits
            )

            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Method"
            )
            
            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Glass"
            )
            
            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Garnish"
            )
            
            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Ice"
            )
            
            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Extra"
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
