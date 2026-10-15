//
//  CocktailsSearchEmptyState.swift
//  DrinkoPro
//

import SwiftUI

/// Shown when a search matches no cocktails.
struct CocktailsSearchEmptyState: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    var body: some View {
        ContentUnavailableView(
            label: {
                Label("\"\(viewModel.searchText)\" not found", systemImage: "exclamationmark.magnifyingglass")
            },
            description: {
                Text("No cocktails match \"\(viewModel.searchText)\". Try a different search term or browse all cocktails.")
            },
            actions: {
                Button("Clear Search", systemImage: "xmark.circle") {
                    viewModel.searchText = ""
                }
                .buttonStyle(.bordered)
            }
        )
    }
}
