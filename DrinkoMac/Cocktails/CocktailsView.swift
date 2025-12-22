//
//  CocktailsView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 18/12/2025.
//

import SwiftUI

struct CocktailsView: View {
    static let cocktailsTag: String? = "Cocktails"
    @Environment(CocktailsViewModel.self) private var cocktailsViewModel
    @State private var selectedCocktail: Cocktail?

    var body: some View {
        @Bindable var cocktailsVM = cocktailsViewModel
        
        NavigationSplitView {
            List(
                cocktailsVM.listOfAllDrinks,
                selection: $selectedCocktail
            ) { cocktail in
                CocktailRowView(cocktail: cocktail)
                    .tag(cocktail)
            }
        } detail: {
            if let selectedCocktail = selectedCocktail {
                CocktailDetailView(cocktail: selectedCocktail)
                    .tag(selectedCocktail)
            } else {
                ContentUnavailableView(
                    "No Cocktail Selected",
                    systemImage: "wineglass",
                    description: Text("Select a cocktail from the sidebar to check the recipe.")
                )

            }
        }
    }
}

#Preview {
    CocktailsView()
}
