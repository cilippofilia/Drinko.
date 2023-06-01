//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct CocktailsView: View {
    static let cocktailsTag: String? = "Cocktails"

    @StateObject var favorites = Favorites()
    @State private var cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    @State private var searchText = ""

    var filteredCocktails: [Cocktail] {
        guard !searchText.isEmpty else { return cocktails }
        return cocktails.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredCocktails, id:\.id) { cocktail in
                CocktailRowView(favorites: favorites, cocktail: cocktail)
                    .contextMenu {
                        FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                    }
            }
            .navigationTitle("Cocktails")
            .searchable(text: $searchText, prompt: "Search Cocktails")
        }
        .environmentObject(favorites)
    }
}

struct CocktailsView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailsView()
    }
}
