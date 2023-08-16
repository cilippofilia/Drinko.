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
    @State private var sortOption: SortOption = .fromAtoZ

    enum SortOption {
        case fromAtoZ
        case fromZtoA
        case byGlass
        case byIce
    }

    var sortSymbol: String {
        switch sortOption {
        case .fromAtoZ:
            return "arrow.up.arrow.down"
        case .fromZtoA:
            return "arrow.up.arrow.down"
        case .byGlass:
            return "arrow.up.arrow.down"
        case .byIce:
            return "arrow.up.arrow.down"
        }
    }

    var sortedCocktails: [Cocktail] {
        switch sortOption {
        case .fromAtoZ:
            return cocktails.sorted { $0.name < $1.name }
        case .fromZtoA:
            return cocktails.sorted { $1.name < $0.name }
        case .byGlass:
            return cocktails.sorted { $0.glass < $1.glass }
        case .byIce:
            return cocktails.sorted { $0.ice < $1.ice }
        }
    }

    var filteredCocktails: [Cocktail] {
        guard !searchText.isEmpty else { return sortedCocktails }
        return sortedCocktails.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(filteredCocktails, id:\.id) { cocktail in
            CocktailRowView(favorites: favorites, cocktail: cocktail)
                .contextMenu {
                    FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                }
        }
        .navigationTitle("Cocktails")
        .searchable(text: $searchText, prompt: "Search Cocktails")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("A -> Z") {
                        sortOption = .fromAtoZ
                    }
                    
                    Button("Z -> A") {
                        sortOption = .fromZtoA
                    }
                    
                    Button("By Glass") {
                        sortOption = .byGlass
                    }
                    
                    Button("By Ice") {
                        sortOption = .byIce
                    }
                    
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .environmentObject(favorites)
    }
}

struct FavoriteButtonView: View {
    let favorites: Favorites
    let cocktail: Cocktail

    var body: some View {
        Button(action: {
            if favorites.contains(cocktail) {
                favorites.remove(cocktail)
            } else {
                favorites.add(cocktail)
            }
        }) {
            Image(systemName: favorites.contains(cocktail) ?
                  "heart.slash" : "heart")
            Text("Like")
        }
    }
}

#if DEBUG
struct CocktailsView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailsView()
    }
}
#endif
