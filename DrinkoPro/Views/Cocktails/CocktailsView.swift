//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct CocktailsView: View {
    static let cocktailsTag: String? = "Cocktails"
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @StateObject var favorites = Favorites()

    @State private var cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    @State private var searchText = ""
    @State private var showingSortOrder = false
    @State private var sortOption: SortOption = .fromAtoZ

    private let compactColumn = [
        GridItem(.flexible(minimum: 240,
                           maximum: 480),
                 spacing: 20,
                 alignment: .leading),
    ]

    private let regularColumns = [
        GridItem(.flexible(minimum: 240,
                           maximum: 480),
                 spacing: 20,
                 alignment: .leading),

        GridItem(.flexible(minimum: 240,
                           maximum: 480),
                 spacing: 20,
                 alignment: .leading),
    ]
    
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
        if sizeClass == .compact {
            compactCocktails
        } else {
            regularCocktails
        }
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

private extension CocktailsView {
    var regularCocktails: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: regularColumns) {
                    ForEach(cocktails, id:\.id) { cocktail in
                        CocktailRowView(favorites: favorites, cocktail: cocktail)
                            .contextMenu {
                                FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                            }
                            .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Cocktails")
            .searchable(text: $searchText, prompt: "Search Cocktails")
            .toolbar {
                sortButtonToolbarItem
            }
        }
        .environmentObject(favorites)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var compactCocktails: some View {
        NavigationStack {
            List(filteredCocktails) { cocktail in
                CocktailRowView(favorites: favorites, cocktail: cocktail)
                    .contextMenu {
                        FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                    }
            }
            .navigationTitle("Cocktails")
            .searchable(text: $searchText, prompt: "Search Cocktails")
            .toolbar {
                sortButtonToolbarItem
            }
        }
        .environmentObject(favorites)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private extension CocktailsView {
    var sortButtonToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showingSortOrder.toggle()
            } label: {
                if UIAccessibility.isVoiceOverRunning {
                    Text("Sort cocktails")
                } else {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            .confirmationDialog("Sort cocktails",
                                isPresented: $showingSortOrder) {
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
            }
        }
    }
}

#Preview {
    CocktailsView()
}
