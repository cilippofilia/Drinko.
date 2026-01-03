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

    var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarTrailing
        #elseif os(macOS)
        return .automatic
        #endif
    }
    let cocktail: Cocktail

    var body: some View {
        ScrollView {
            cocktailContent
        }
        .navigationTitle(cocktail.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                HistoryButtonView(
                    history: viewModel.getCocktailHistory(for: cocktail),
                    showHistory: $showHistory,
                    cocktail: cocktail
                )
            }
            ToolbarItem(placement: toolbarPlacement) {
                LikeButtonView(cocktail: cocktail)
                    .frame(minWidth: 30, minHeight: 30)
            }
        }
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
        #elseif os(macOS)
        .padding(.horizontal, 20)
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
