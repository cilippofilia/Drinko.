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
    @State private var showingSortOrder = false
    @State private var sortOption: SortOption = .fromAtoZ

    enum SortOption {
        case fromAtoZ
        case fromZtoA
        case byGlass
        case byIce
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
        List(filteredCocktails) { cocktail in
            CocktailRowView(favorites: favorites, cocktail: cocktail)
                .contextMenu {
                    FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                }
        }
        .navigationTitle("Cocktails")
        .searchable(text: $searchText, prompt: "Search Cocktails")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSortOrder.toggle()
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .actionSheet(isPresented: $showingSortOrder, content: {
            ActionSheet(title: Text("Sort cocktails"),
                        message: nil,
                        buttons: [
                            .default(Text("A -> Z")) {
                                sortOption = .fromAtoZ
                            },
                            .default(Text("Z -> A")) {
                                sortOption = .fromZtoA
                            },
                            .default(Text("By Glass")) {
                                sortOption = .byGlass
                            },
                            .default(Text("By Ice")) {
                                sortOption = .byIce
                            },
                            .cancel()
                        ])
        })
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
