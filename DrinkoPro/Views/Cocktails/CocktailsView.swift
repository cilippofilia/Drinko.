//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct CocktailsView: View {
    @StateObject var favorites = Favorites()
    static let cocktailsTag: String? = "Cocktails"

    @State private var searchText = ""

    let cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")

    var body: some View {
        NavigationStack {
            List(cocktails, id:\.id) { cocktail in
                CocktailRowView(favorites: favorites, cocktail: cocktail)
                    .contextMenu {
                        FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                    }
            }
            .navigationTitle("Cocktails")
        }
        .environmentObject(favorites)
    }
}

struct CocktailsView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailsView()
    }
}
