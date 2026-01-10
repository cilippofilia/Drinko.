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
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
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
        #endif
    }
    
    var cocktailContent: some View {
        VStack {
            CocktailImageHeader(cocktail: cocktail)
            
            VStack(alignment: .leading) {
                CocktailUnitPicker(selectedUnit: $selectedUnit)
                
                Text(cocktail.name)
                    .font(.title.bold())
                
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
        #if os(iOS)
        .frame(width: screenWidth * (sizeClass == .compact ? 0.9 : 0.7))
        #endif
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
