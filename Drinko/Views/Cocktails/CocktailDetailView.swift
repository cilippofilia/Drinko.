//
//  CocktailDetailView.swift
//  Drinko
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailDetailView: View {
    @ObservedObject var favorites = Favorites()

    var cocktail: Cocktail

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                CocktailDetailSectionView(cocktail: cocktail, text: "Ingredients")

                ForEach(cocktail.ingredients) { ingredient in
                    HStack {
                        Text("\(ingredient.quantity, specifier: "%2g")")
                        Text(ingredient.unit)
                        Text(ingredient.name.capitalized)
                    }
                }

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Method")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Glass")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Garnish")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Ice")

                CocktailDetailSectionView(cocktail: cocktail,
                                          text: "Extra")

                VStack {
                    FavoritesButton(cocktail: cocktail)
                }
                .padding(.vertical)
            }
            .frame(width: screenWidthPlusMargins)
        }
        .navigationTitle(cocktail.name)
    }
}

struct CocktailDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailDetailView(cocktail: .example, history: .example)
    }
}
