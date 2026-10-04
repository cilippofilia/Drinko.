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
    @AppStorage(LibraryLayout.storageKey) private var layout: LibraryLayout = .list
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

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            contentView
                .navigationTitle("Cocktails")
                .searchable(text: searchBinding, prompt: "Search Cocktails")
                .toolbar {
                    ToolbarItemGroup(placement: toolbarPlacement) {
                        optionsMenu
                        LibraryLayoutToggle(layout: $layout)
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
                .safeAreaInset(edge: .bottom) {
                    CrossPromoBannerView()
                }
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
                ContentUnavailableView(
                    "Select a Cocktail",
                    systemImage: "wineglass",
                    description: Text("Choose a cocktail to see its details.")
                )
            }
        }
    }
}

private extension CocktailsView {
    var contentView: some View {
        Group {
            if shouldShowFilterEmptyState {
                filterEmptyStateView
            } else if !viewModel.searchText.isEmpty && visibleCocktails.isEmpty {
                searchEmptyStateView
            } else {
                LibraryView(
                    recentsTitle: String(localized: "Last Viewed"),
                    recents: viewModel.recentItems(from: recentsStore.ids(in: .cocktails)),
                    sections: visibleSections,
                    selection: selectedCocktail,
                    isSearching: !viewModel.searchText.isEmpty,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    onSelect: select,
                    cardModel: { viewModel.cardModel(for: $0) },
                    contextMenu: { cocktail in
                        FavoriteCocktailButtonView(cocktail: cocktail)
                        if cocktail.id.hasPrefix("user-") {
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
        .accessibilityLabel("Filter cocktails")
    }

    var shouldShowFilterEmptyState: Bool {
        (filterOption == .favoritesOnly || showsOnlyUserCocktails) && visibleCocktails.isEmpty
    }

    var showsOnlyUserCocktails: Bool {
        filterOption == .userCreatedOnly || listSource == .userOnly
    }

    var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        )
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
        Menu {
            CocktailFilterSection(
                filterOption: $filterOption,
                availableOptions: availableFilterOptions
            )

            Section("Sort") {
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
            }
        } label: {
            #if os(iOS)
            if UIAccessibility.isVoiceOverRunning {
                Text("Filter and sort cocktails")
            } else {
                Label("Options", systemImage: "line.3.horizontal.decrease.circle")
            }
            #elseif os(macOS)
            Label("Options", systemImage: "line.3.horizontal.decrease.circle")
            #endif
        }
        .accessibilityLabel("Sort cocktails")
    }

    var addCocktailButton: some View {
        Button {
            showCreateCocktailSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .accessibilityLabel("Create Cocktail")
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
