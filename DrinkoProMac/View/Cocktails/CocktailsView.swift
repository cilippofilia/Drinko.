//
//  CocktailsView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct CocktailsView: View {
    @State private var viewModel = CocktailsViewModel()
    @State private var selectedCocktail: Cocktail?
    var favorites = Favorites()

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCocktail) {
                ForEach(viewModel.listOfCocktails, id: \.id) { cocktail in
                    CocktailRowView(
                        cocktail: cocktail,
                        favorites: favorites
                    )
                }
            }
        } detail: {
            if let cocktail = selectedCocktail {
                DetailCocktailsView(
                    cocktail: cocktail,
                    procedure: viewModel.getCocktailProcedure(for: cocktail),
                    linkedCocktails: viewModel.getLinkedCocktails(for: cocktail),
                    favorites: favorites
                )
            } else {
                UnselectedView(
                    image: "wineglass.fill",
                    title: "Welcome to Drinko Cocktails",
                    subtitle: "Select a cocktail from the sidebar to get started."
                )
            }
        }
    }
}

#Preview {
    CocktailsView(favorites: Favorites())
}
