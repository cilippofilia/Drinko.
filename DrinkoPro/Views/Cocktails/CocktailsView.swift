//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftData
import SwiftUI

struct CocktailsView: View {
    static let cocktailsTag: String? = "Cocktails"

    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    @Environment(\.modelContext) private var modelContext
    @Environment(RecentsStore.self) private var recentsStore

    @AppStorage(CocktailListSource.storageKey) private var listSource: CocktailListSource = .userAndApp
    @State private var filterOption: CocktailsViewModel.FilterOption = .all
    @State private var showCreateCocktailSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var cocktailPendingDeletion: Cocktail = .userCreatedExample
    @State private var didConfigureModelContext: Bool = false

    @State private var selectedCocktail: Cocktail?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @AppStorage(LibraryLayout.cocktailsStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage("cocktailsCollapsedSections") private var collapsedSections = CollapsedSections()

    private var visibleCocktails: [Cocktail] {
        viewModel.filteredCocktails(filterOption: filterOption, source: listSource) { cocktail in
            favorites.contains(cocktail)
        }
    }

    private var visibleSections: [LibrarySection<Cocktail>] {
        viewModel.librarySections(filterOption: filterOption, source: listSource) { cocktail in
            favorites.contains(cocktail)
        }
    }

    private var availableFilterOptions: [CocktailsViewModel.FilterOption] {
        viewModel.availableFilterOptions(for: listSource)
    }

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarTrailing
        #else
        return .automatic
        #endif
    }

    private var layoutTogglePlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .automatic
        #endif
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            contentView
                .navigationTitle("Cocktails")
                .searchable(text: $viewModel.searchText, prompt: "Search Cocktails")
                .toolbar {
                    ToolbarItem(placement: layoutTogglePlacement) {
                        LibraryLayoutToggle(layout: $layout)
                    }
                    ToolbarItemGroup(placement: toolbarPlacement) {
                        optionsMenu
                        addCocktailButton
                    }
                }
                .sheet(isPresented: $showCreateCocktailSheet) {
                    #if os(iOS)
                    NavigationStack {
                        UserCocktailForm(
                            methodOptions: viewModel.methodOptions(),
                            glassOptions: viewModel.glassOptions(),
                            iceOptions: viewModel.iceOptions(),
                            unitOptions: viewModel.unitOptions()
                        )
                    }
                    #else
                    MacUserCocktailForm(
                        methodOptions: viewModel.methodOptions(),
                        glassOptions: viewModel.glassOptions(),
                        iceOptions: viewModel.iceOptions(),
                        unitOptions: viewModel.unitOptions()
                    )
                    #endif
                }
                .alert("Delete Cocktail?", isPresented: $showDeleteAlert) {
                    DeleteButtonView(
                        label: "Delete",
                        action: {
                            viewModel.deleteUserCocktail(cocktailPendingDeletion)
                            if favorites.contains(cocktailPendingDeletion) {
                                favorites.remove(cocktailPendingDeletion)
                            }
                            recentsStore.remove(cocktailPendingDeletion.id, in: .cocktails)
                            if selectedCocktail == cocktailPendingDeletion {
                                selectedCocktail = nil
                                preferredCompactColumn = .sidebar
                            }
                        }
                    )
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will permanently remove your cocktail.")
                }
                .task {
                    if !didConfigureModelContext {
                        viewModel.configure(modelContext: modelContext)
                        didConfigureModelContext = true
                    }
                    openPendingCocktailIfNeeded()
                }
                .onChange(of: appNavigationModel.pendingCocktailID, initial: true) { _, _ in
                    openPendingCocktailIfNeeded()
                }
                .onChange(of: listSource) { _, _ in
                    // Drop a filter or selection the new source can no longer show.
                    if !availableFilterOptions.contains(filterOption) {
                        filterOption = .all
                    }
                    if let selectedCocktail, !visibleCocktails.contains(selectedCocktail) {
                        self.selectedCocktail = nil
                        preferredCompactColumn = .sidebar
                    }
                }
                #if os(iOS) || os(macOS)
                .crossPromoBanner()
                #endif
        } detail: {
            if let selectedCocktail {
                NavigationStack {
                    CocktailDetailView(cocktail: selectedCocktail)
                        .navigationDestination(for: Cocktail.self) { cocktail in
                            CocktailDetailView(cocktail: cocktail)
                        }
                }
                // Reset pushed "You may also like" pages when the sidebar selection changes.
                .id(selectedCocktail.id)
            } else {
                // Hosted in a stack like the selected state, so the detail column's bar
                // (and the sidebar toggle in it) sits under the tab bar the same way.
                NavigationStack {
                    ContentUnavailableView(
                        "Select a Cocktail",
                        systemImage: "wineglass",
                        description: Text("Choose a cocktail to see its details.")
                    )
                }
            }
        }
    }
}

private extension CocktailsView {
    var contentView: some View {
        let sections = visibleSections

        return Group {
            if shouldShowFilterEmptyState(sections) {
                filterEmptyStateView
            } else if !viewModel.searchText.isEmpty && sections.isEmpty {
                searchEmptyStateView
            } else {
                LibraryView(
                    recentsTitle: String(localized: "Last Viewed"),
                    recents: viewModel.recentItems(from: recentsStore.ids(in: .cocktails)),
                    sections: sections,
                    selection: selectedCocktail,
                    isSearching: !viewModel.searchText.isEmpty,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    onSelect: select,
                    cardModel: { viewModel.cardModel(for: $0, isFavorite: favorites.contains($0)) },
                    contextMenu: { cocktail in
                        FavoriteCocktailButtonView(cocktail: cocktail)
                        if cocktail.isUserCreated {
                            DeleteButtonView(
                                label: "Delete",
                                action: {
                                    cocktailPendingDeletion = cocktail
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                )
            }
        }
    }

    func shouldShowFilterEmptyState(_ sections: [LibrarySection<Cocktail>]) -> Bool {
        (filterOption == .favoritesOnly || showsOnlyUserCocktails) && sections.isEmpty
    }

    var showsOnlyUserCocktails: Bool {
        filterOption == .userCreatedOnly || listSource == .userOnly
    }

    var filterEmptyStateView: some View {
        ContentUnavailableView(
            label: {
                if filterOption == .favoritesOnly && viewModel.searchText.isEmpty {
                    Label("No favorite cocktails yet", systemImage: "heart.slash")
                } else if showsOnlyUserCocktails && viewModel.searchText.isEmpty {
                    Label("No custom cocktails yet", systemImage: "plus.circle")
                } else {
                    Label("No cocktails found", systemImage: "exclamationmark.magnifyingglass")
                }
            },
            description: {
                if filterOption == .favoritesOnly && viewModel.searchText.isEmpty {
                    Text("Add cocktails to favorites to quickly find them here.")
                } else if showsOnlyUserCocktails && viewModel.searchText.isEmpty {
                    Text("Create a cocktail to find it here.")
                } else {
                    Text("No cocktails match \"\(viewModel.searchText)\".")
                }
            },
            actions: {
                if filterOption == .userCreatedOnly || filterOption == .favoritesOnly {
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

    var searchEmptyStateView: some View {
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

    var optionsMenu: some View {
        @Bindable var viewModel = viewModel

        return Menu {
            CocktailFilterSection(
                filterOption: $filterOption,
                availableOptions: availableFilterOptions
            )

            Section("Sort") {
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.inline)
            }
        } label: {
            Label("Filter and Sort", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    var addCocktailButton: some View {
        Button("Create Cocktail", systemImage: "plus") {
            showCreateCocktailSheet = true
        }
    }

    @MainActor
    func openPendingCocktailIfNeeded() {
        guard let cocktailID = appNavigationModel.consumePendingCocktailID() else { return }
        guard let cocktail = viewModel.listOfAllDrinks.first(where: { $0.id == cocktailID }) else { return }

        select(cocktail)
    }

    /// Opens `cocktail` in the detail column, pushing it on compact widths, and records it as recent.
    func select(_ cocktail: Cocktail) {
        selectedCocktail = cocktail
        preferredCompactColumn = .detail
        recentsStore.record(cocktail.id, in: .cocktails)
    }
}

#if DEBUG
#Preview {
    CocktailsView()
        .drinkoPreviewEnvironment()
}
#endif
