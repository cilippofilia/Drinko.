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
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    @State private var showingSortOrder = false
    @State var path = NavigationPath()

    var favoriteCocktailsTip = SwipeToFavoriteTip()

    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.filteredCocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    CocktailRowView(cocktail: cocktail)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            FavoriteCocktailButtonView(cocktail: cocktail)
                                .tint(favorites.contains(cocktail) ? .red : .blue)
                        }
                }
            }
            .navigationTitle("Cocktails")
            .navigationDestination(for: Cocktail.self) { cocktail in
                CocktailDetailView(cocktail: cocktail)
            }
            .searchable(
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 }
                ),
                prompt: "Search Cocktails"
            )
            .popoverTip(favoriteCocktailsTip)
            .toolbar {
                sortButtonMenu
            }
            .task {
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
        }
    }
}

private extension CocktailsView {
    var sortButtonMenu: some View {
        Menu {
            Button(action: {
                viewModel.sortOption = .fromAtoZ
            }) {
                Label("A > Z", systemImage: viewModel.sortOption == .fromAtoZ ? "checkmark" : "")
            }
            Button(action: {
                viewModel.sortOption = .fromZtoA
            }) {
                Label("Z > A", systemImage: viewModel.sortOption == .fromZtoA ? "checkmark" : "")
            }
            Button(action: {
                viewModel.sortOption = .byGlass
            }) {
                Label("By Glass", systemImage: viewModel.sortOption == .byGlass ? "checkmark" : "")
            }
            Button(action: {
                viewModel.sortOption = .byIce
            }) {
                Label("By Ice", systemImage: viewModel.sortOption == .byIce ? "checkmark" : "")
            }
        } label: {
            if UIAccessibility.isVoiceOverRunning {
                Text("Sort cocktails")
            } else {
                Label("Sort", systemImage: "arrow.up.arrow.down")
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
