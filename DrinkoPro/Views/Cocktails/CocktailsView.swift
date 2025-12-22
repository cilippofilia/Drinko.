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
            Group {
                if viewModel.searchText.isEmpty {
                    List {
                        ForEach(viewModel.sortedSectionKeys, id: \.self) { sectionKey in
                            Section {
                                ForEach(viewModel.cocktailsGrouped[sectionKey] ?? []) { cocktail in
                                    NavigationLink(value: cocktail) {
                                        CocktailRowView(cocktail: cocktail)
                                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                                FavoriteCocktailButtonView(cocktail: cocktail)
                                                    .tint(favorites.contains(cocktail) ? .red : .blue)
                                            }
                                    }
                                }
                            } header: {
                                Text(sectionKey)
                            }
                        }
                    }
                } else {
                    List(viewModel.filteredCocktails) { cocktail in
                        NavigationLink(value: cocktail) {
                            CocktailRowView(cocktail: cocktail)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    FavoriteCocktailButtonView(cocktail: cocktail)
                                        .tint(favorites.contains(cocktail) ? .red : .blue)
                                }
                        }
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
                HStack {
                    Text("A > Z")
                    if viewModel.sortOption == .fromAtoZ {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: {
                viewModel.sortOption = .fromZtoA
            }) {
                HStack {
                    Text("Z > A")
                    if viewModel.sortOption == .fromZtoA {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: {
                viewModel.sortOption = .byGlass
            }) {
                HStack {
                    Text("By Glass")
                    if viewModel.sortOption == .byGlass {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: {
                viewModel.sortOption = .byIce
            }) {
                HStack {
                    Text("By Ice")
                    if viewModel.sortOption == .byIce {
                        Image(systemName: "checkmark")
                    }
                }
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
