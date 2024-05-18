//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI
import TipKit

struct CocktailsView: View {
    static let cocktailsTag: String? = "Cocktails"
    
    @Environment(\.horizontalSizeClass) var sizeClass
        
    @State private var cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    @State private var shots = Bundle.main.decode([Cocktail].self, from: "shots.json")
    @State private var searchText = ""
    @State private var showingSortOrder = false
    @State private var sortOption: SortOption = .fromAtoZ
        
    var favorites = Favorites()
    var favoriteCocktailsTip = SwipeToFavoriteTip()
    
    var drinklist: [Cocktail] {
        let list = cocktails + shots
        
        return list
    }
    
    var sortedCocktails: [Cocktail] {
        switch sortOption {
        case .fromAtoZ:
            return drinklist.sorted { $0.name < $1.name }
        case .fromZtoA:
            return drinklist.sorted { $1.name < $0.name }
        case .byGlass:
            return drinklist.sorted { $0.glass < $1.glass }
        case .byIce:
            return drinklist.sorted { $0.ice < $1.ice }
        }
    }

    var filteredCocktails: [Cocktail] {
        guard !searchText.isEmpty else { return sortedCocktails }
        return sortedCocktails.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredCocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    CocktailRowView(favorites: favorites, cocktail: cocktail)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            FavoriteCocktailButtonView(favorites: favorites, cocktail: cocktail)
                                .tint(favorites.contains(cocktail) ? .red : .blue)
                        }
                }
            }
            .navigationTitle("Cocktails")
            .navigationDestination(for: Cocktail.self) { cocktail in
                CocktailDetailView(favorites: favorites, cocktail: cocktail)
            }
            .searchable(text: $searchText, prompt: "Search Cocktails")
            .popoverTip(favoriteCocktailsTip)
            .toolbar {
                sortButtonToolbarItem
            }
            .task {
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
        }
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

#if DEBUG
#Preview {
    NavigationStack {
        CocktailsView()
    }
}
#endif
