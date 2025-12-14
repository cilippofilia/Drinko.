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
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    
    var units = ["ml", "oz."]

    @State private var showHistory = false
    @State private var showProcedure = false

    @State private var selectedUnit = "ml"

    let cocktail: Cocktail

    var body: some View {
        ScrollView {
            cocktailContent
        }
        .navigationTitle(cocktail.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HistoryButtonView(
                    history: viewModel.getCocktailHistory(for: cocktail),
                    showHistory: $showHistory,
                    cocktail: cocktail
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                LikeButtonView(cocktail: cocktail)
            }
        }
    }
    
    var cocktailContent: some View {
        VStack {
            CocktailImageHeader(cocktail: cocktail)
            
            VStack(alignment: .leading) {
                Text(cocktail.name)
                    .font(.title.bold())

                CocktailUnitPicker(selectedUnit: $selectedUnit)
                
                Divider()
                
                CocktailDetailsSection(
                    cocktail: cocktail,
                    selectedUnit: selectedUnit
                )
                
                Divider()

                CocktailRelatedSection(cocktail: cocktail)
            }
            Spacer(minLength: 50)
        }
        .frame(width: screenWidth * (sizeClass == .compact ? 0.9 : 0.7))
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
