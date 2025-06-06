//
//  CocktailDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var favorites = Favorites()
    var units = ["ml", "oz."]

    @State private var viewModel = CocktailsViewModel()

    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "ml"

    let cocktail: Cocktail

    var body: some View {
        ScrollView {
            if sizeClass == .compact {
                compactDetailView
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HistoryButtonView(
                                history: viewModel.getCocktailHistory(for: cocktail),
                                showHistory: $showHistory,
                                cocktail: cocktail
                            )
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            LikeButtonView(favorites: favorites, cocktail: cocktail)
                        }
                    }
            } else {
                regularDetailView
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HistoryButtonView(
                                history: viewModel.getCocktailHistory(for: cocktail),
                                showHistory: $showHistory,
                                cocktail: cocktail
                            )
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            LikeButtonView(favorites: favorites, cocktail: cocktail)
                        }
                    }
            }
        }
        .navigationTitle(cocktail.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }

    var compactDetailView: some View {
        VStack {
            AsyncImageView(
                image: cocktail.pic,
                frameHeight: imageFrameHeight,
                aspectRatio: .fit
            )
            .frame(width: compactScreenWidth)
            .background(Color.white)
            .cornerRadius(imageCornerRadius)

            VStack(alignment: .leading) {
                Text(cocktail.name)
                    .font(.title.bold())

                Picker("Select unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: compactScreenWidth / 2)
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
                    if let procedure = viewModel.getCocktailProcedure(for: cocktail) {
                        ProcedureView(
                            cocktail: cocktail,
                            procedure: procedure
                        )
                    }

                    if !viewModel.getLinkedCocktails(for: cocktail).isEmpty {
                        Text("You may also like")
                            .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                            .padding(.vertical)

                        LinkedCocktailsView(
                            cocktails: viewModel.getLinkedCocktails(for: cocktail),
                            procedure: viewModel.getCocktailProcedure(for: cocktail),
                            favorites: favorites
                        )
                    }
                }
                .padding(.vertical)
            }
            Spacer(minLength: 50)
        }
        .frame(width: compactScreenWidth)
    }

    var regularDetailView: some View {
        VStack {
            AsyncImageView(
                image: cocktail.pic,
                frameHeight: imageFrameHeight,
                aspectRatio: .fit
            )
            .frame(width: regularScreenWidth)
            .background(Color.white)
            .cornerRadius(imageCornerRadius)

            VStack(alignment: .leading) {
                Text(cocktail.name)
                    .font(.title.bold())

                Picker("Select unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: regularScreenWidth / 2)
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
                    if let procedure = viewModel.getCocktailProcedure(for: cocktail) {
                        ProcedureView(
                            cocktail: cocktail,
                            procedure: procedure
                        )
                    }
                    if !viewModel.getLinkedCocktails(for: cocktail).isEmpty {
                        Text("You may also like")
                            .font(sizeClass == .compact ? .title3.bold() : .title.bold())
                            .padding(.vertical)

                        LinkedCocktailsView(
                            cocktails: viewModel.getLinkedCocktails(for: cocktail),
                            procedure: viewModel.getCocktailProcedure(for: cocktail),
                            favorites: favorites
                        )
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(width: regularScreenWidth)
    }
}

#if DEBUG
#Preview {
    TabView {
        NavigationStack {
            CocktailDetailView(cocktail: .example)
                .environment(Favorites())
        }
    }
}
#endif
