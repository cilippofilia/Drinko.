//
//  CocktailsLibraryContent.swift
//  DrinkoPro
//

import SwiftUI

/// The Cocktails library column's content: the library, or an empty state when the filter or
/// search leaves nothing to show.
struct CocktailsLibraryContent: View {
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites

    let title: String
    let recents: [Cocktail]
    let sections: [LibrarySection<Cocktail>]
    /// The cocktail currently shown, highlighted in the library.
    let selection: Cocktail?
    /// A fixed filter for the page (an iPad sidebar row). `nil` lets the user pick one.
    let presetFilter: CocktailsViewModel.FilterOption?
    @Binding var filterOption: CocktailsViewModel.FilterOption
    let listSource: CocktailListSource
    @Binding var collapsedSections: CollapsedSections
    let layout: LibraryLayout
    let onSelect: @MainActor (Cocktail) -> Void
    /// Asks the page to confirm deleting a user-created cocktail.
    let onRequestDelete: @MainActor (Cocktail) -> Void

    private var showsOnlyUserCocktails: Bool {
        filterOption == .userCreatedOnly || listSource == .userOnly
    }

    private var shouldShowFilterEmptyState: Bool {
        (filterOption == .favoritesOnly || filterOption == .shotsOnly || showsOnlyUserCocktails) && sections.isEmpty
    }

    var body: some View {
        Group {
            if shouldShowFilterEmptyState {
                CocktailsFilterEmptyState(
                    filterOption: $filterOption,
                    presetFilter: presetFilter,
                    showsOnlyUserCocktails: showsOnlyUserCocktails
                )
            } else if !viewModel.searchText.isEmpty && sections.isEmpty {
                CocktailsSearchEmptyState()
            } else {
                LibraryView(
                    title: title,
                    recentsTitle: String(localized: "Last Viewed"),
                    recents: recents,
                    sections: sections,
                    selection: selection,
                    isSearching: !viewModel.searchText.isEmpty,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    onSelect: onSelect,
                    cardModel: { viewModel.cardModel(for: $0, isFavorite: favorites.contains($0)) },
                    contextMenu: { cocktail in
                        FavoriteCocktailButtonView(cocktail: cocktail)
                        if cocktail.isUserCreated {
                            DeleteButtonView(
                                label: "Delete",
                                action: { onRequestDelete(cocktail) }
                            )
                        }
                    }
                )
                // Cocktail names are short, so one caption line keeps the cards compact.
                .environment(\.libraryCardCaptionLines, 1)
            }
        }
    }
}
