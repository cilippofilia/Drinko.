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
    @StateObject var userCocktailVM: ViewModel
    
    @State private var cocktails = Bundle.main.decode([Cocktail].self, from: "cocktails.json")
    @State private var shots = Bundle.main.decode([Cocktail].self, from: "shots.json")
    @State private var searchText = ""
    @State private var showingSortOrder = false
    @State private var sortOption: Cocktail.SortOption = .fromAtoZ
    
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _userCocktailVM = StateObject(wrappedValue: viewModel)
    }
    
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
                /// added to the first cocktail on the list - might change with future updates
                if #available(iOS 17.0, *), (cocktail.id == "adonis") {
                    TipView(favoriteCocktailsTip, arrowEdge: .bottom)
                        .background(Color.clear)
                }
                
                CocktailRowView(favorites: favorites, cocktail: cocktail)
                    .swipeActions(edge: .trailing) {
                        FavoriteButtonView(favorites: favorites, cocktail: cocktail)
                            .tint(favorites.contains(cocktail) ? .red : .blue)
                    }
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
    NavigationStack {
        CocktailsView(dataController: DataController())
    }
}
