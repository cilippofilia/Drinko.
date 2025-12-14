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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CocktailDetailSectionView(
                cocktail: cocktail,
                text: "Ingredients"
            )
            
            IngredientsView(
                ingredients: cocktail.ingredients,
                selectedUnit: selectedUnit
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
        .padding(.vertical)
    }
}

#if DEBUG
#Preview {
    CocktailDetailsSection(cocktail: .example, selectedUnit: "ml")
}
#endif
