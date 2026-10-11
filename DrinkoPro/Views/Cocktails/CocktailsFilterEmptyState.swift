//
//  CocktailsFilterEmptyState.swift
//  DrinkoPro
//

import SwiftUI

/// Shown when the active filter (favorites, shots, custom cocktails) leaves no cocktails.
struct CocktailsFilterEmptyState: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    @Binding var filterOption: CocktailsViewModel.FilterOption
    /// A fixed filter for the page; its "Clear filter" action is hidden when set.
    let presetFilter: CocktailsViewModel.FilterOption?
    /// Whether the page can only show the user's own cocktails (a filter or the list source).
    let showsOnlyUserCocktails: Bool

    var body: some View {
        ContentUnavailableView(
            label: {
                if filterOption == .favoritesOnly && viewModel.searchText.isEmpty {
                    Label("No favorite cocktails yet", systemImage: "heart.slash")
                } else if filterOption == .shotsOnly && viewModel.searchText.isEmpty {
                    Label("No shots to show", systemImage: "drop")
                } else if showsOnlyUserCocktails && viewModel.searchText.isEmpty {
                    Label("No custom cocktails yet", systemImage: "plus.circle")
                } else {
                    Label("No cocktails found", systemImage: "exclamationmark.magnifyingglass")
                }
            },
            description: {
                if filterOption == .favoritesOnly && viewModel.searchText.isEmpty {
                    Text("Add cocktails to favorites to quickly find them here.")
                } else if filterOption == .shotsOnly && viewModel.searchText.isEmpty {
                    Text("Your list source doesn't include Drinko's shots.")
                } else if showsOnlyUserCocktails && viewModel.searchText.isEmpty {
                    Text("Create a cocktail to find it here.")
                } else {
                    Text("No cocktails match \"\(viewModel.searchText)\".")
                }
            },
            actions: {
                if presetFilter == nil, filterOption == .userCreatedOnly || filterOption == .favoritesOnly {
                    Button("Clear filter", systemImage: "xmark.circle") {
                        filterOption = .all
                    }
                    .buttonStyle(.bordered)
                }
                if !viewModel.searchText.isEmpty {
                    Button("Clear Search", systemImage: "xmark.circle") {
                        viewModel.searchText = ""
                    }
                    .buttonStyle(.bordered)
                }
            }
        )
    }
}
