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
    @StateObject var favorites = Favorites()
    
    @State private var cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    @State private var shots = Bundle.main.decode([Cocktail].self, from: "shots.json")
    
    @State private var searchText = ""
    @State private var showingSortOrder = false
    @State private var sortOption: Cocktail.SortOption = .fromAtoZ
    
    // TipKit variable
    var favoriteCocktailsTip = SwipeToFavoriteTip()
    
    var drinklist: [Cocktail] {
        return cocktails + shots
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
                /// conditional to make the tip pop up only on devices supporting iOS 17.0 +
                if #available(iOS 17.0, *), (cocktail.id == "adonis") {
                    Spacer()
                        .frame(maxHeight: 50)
                    
                    TipView(favoriteCocktailsTip, arrowEdge: .bottom)
                        .background(Color.clear)
                }

                CocktailRowView(favorites: favorites, cocktail: cocktail)
                    .swipeActions(edge: .trailing) {
                        FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                    }
                    .tint(favorites.contains(cocktail) ? .red : .blue)
            }
            .navigationTitle("Cocktails")
            .searchable(text: $searchText, prompt: "Search Cocktails")
            .toolbar {
                sortButtonToolbarItem
            }
            .task {
                if #available(iOS 17.0, *) {
                    // Configure and load your tips at app launch.
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
            }
        }
        .environmentObject(favorites)
        .navigationViewStyle(StackNavigationViewStyle())
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
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }) {
            Image(systemName: favorites.contains(cocktail) ?
                  "heart.slash" : "heart")
            Text("Like")
        }
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
