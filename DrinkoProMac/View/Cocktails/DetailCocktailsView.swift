//
//  DetailCocktailsView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct DetailCocktailsView: View {
    @State var selectedUnit = "ml"
    var units = ["ml", "oz."]

    let cocktail: Cocktail
    let procedure: Procedure?
    let linkedCocktails: [Cocktail]?
    let favorites: Favorites

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .center) {
                    AsyncImageView(
                        image: cocktail.pic,
                        frameHeight: imageFrameHeight,
                        aspectRatio: .fit
                    )

                    Text(cocktail.name)
                        .font(.title.bold())

                    Picker("", selection: $selectedUnit) {
                        ForEach(units, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: geo.size.width/3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)

                    Divider()

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

                    Divider()

                    VStack(alignment: .leading, spacing: 0) {
                        if let procedure = procedure {
                            ProcedureView(
                                cocktail: cocktail,
                                procedure: procedure
                            )
                        }

                        if let linkedCocktails = linkedCocktails,
                           !linkedCocktails.isEmpty {
                            Text("You may also like")
                                .font(.title.bold())
                                .padding(.vertical)

                            LinkedCocktailsView(
                                cocktails: linkedCocktails,
                                procedure: procedure,
                                favorites: favorites
                            )
                        }
                    }
                    .padding(.vertical)
                }
                .padding()

                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    DetailCocktailsView(cocktail: Cocktail.example, procedure: nil, linkedCocktails: [], favorites: Favorites())
}
