//
//  CocktailsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftData
import SwiftUI

struct CocktailsView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    @Environment(\.modelContext) private var modelContext
    @Environment(RecentsStore.self) private var recentsStore

    @AppStorage(CocktailListSource.storageKey) private var listSource: CocktailListSource = .userAndApp
    /// A fixed filter for this page (an iPad sidebar row). `nil` lets the user pick one.
    private let presetFilter: CocktailsViewModel.FilterOption?
    @State private var filterOption: CocktailsViewModel.FilterOption
    @State private var showCreateCocktailSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var cocktailPendingDeletion: Cocktail = .userCreatedExample
    @State private var didConfigureModelContext: Bool = false

    #if os(iOS)
    @State private var path: [Cocktail] = []
    #else
    @State private var selectedCocktail: Cocktail?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif
    @AppStorage(LibraryLayout.cocktailsStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage("cocktailsCollapsedSections") private var collapsedSections = CollapsedSections()

    init(filter: CocktailsViewModel.FilterOption? = nil) {
        presetFilter = filter
        _filterOption = State(initialValue: filter ?? .all)
    }

    /// The cocktail opened from this page (iOS: the first pushed page, not "You may also like"
    /// pages pushed after it; macOS: the detail column).
    private var currentCocktail: Cocktail? {
        #if os(iOS)
        path.first
        #else
        selectedCocktail
        #endif
    }

    private var title: String {
        presetFilter?.pageTitle ?? String(localized: "Cocktails")
    }

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
        container
            .task(id: currentCocktail?.id) {
                // Record only once the selection settles; a new selection cancels this.
                guard let id = currentCocktail?.id else { return }
                try? await Task.sleep(for: RecentsStore.recordDelay)
                guard !Task.isCancelled else { return }
                recentsStore.record(id, in: .cocktails)
            }
    }

    @ViewBuilder
    private var container: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            library
                .navigationDestination(for: Cocktail.self) { cocktail in
                    CocktailDetailView(cocktail: cocktail)
                }
        }
        #else
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            library
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
        #endif
    }
}

private extension CocktailsView {
    var library: some View {
        @Bindable var viewModel = viewModel

        return contentView
            .navigationTitle(title)
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
                        clearSelection(after: cocktailPendingDeletion)
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
                // Drop a filter or selection the new source can no longer show. A preset
                // filter stays, and its page shows an empty state instead.
                if presetFilter == nil, !availableFilterOptions.contains(filterOption) {
                    filterOption = .all
                }
                if let currentCocktail, !visibleCocktails.contains(currentCocktail) {
                    clearSelection(after: currentCocktail)
                }
            }
            // Catches a user cocktail deleted from another live Cocktails page (iPad).
            #if os(iOS)
            .onChange(of: viewModel.userCocktails.map(\.id)) { _, _ in pruneStalePathEntries() }
            .onAppear(perform: pruneStalePathEntries)
            .crossPromoBanner()
            #elseif os(macOS)
            .crossPromoBanner()
            #endif
    }

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
                    selection: currentCocktail,
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
        (filterOption == .favoritesOnly || filterOption == .shotsOnly || showsOnlyUserCocktails) && sections.isEmpty
    }

    var showsOnlyUserCocktails: Bool {
        filterOption == .userCreatedOnly || listSource == .userOnly
    }

    var filterEmptyStateView: some View {
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
            if presetFilter == nil {
                CocktailFilterSection(
                    filterOption: $filterOption,
                    availableOptions: availableFilterOptions
                )
            }

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
        // Only the main Cocktails page opens deep links; a sidebar filter page that has been
        // opened before stays loaded and must not consume the link.
        guard presetFilter == nil else { return }
        guard let cocktailID = appNavigationModel.consumePendingCocktailID() else { return }
        guard let cocktail = viewModel.listOfAllDrinks.first(where: { $0.id == cocktailID }) else { return }

        select(cocktail)
    }

    /// Opens `cocktail`: pushes it on iOS, shows it in the detail column on macOS. It's
    /// recorded as recent once the selection settles (see the `.task(id:)` in `body`).
    func select(_ cocktail: Cocktail) {
        #if os(iOS)
        path = [cocktail]
        #else
        selectedCocktail = cocktail
        preferredCompactColumn = .detail
        #endif
    }

    /// Stops showing `cocktail` once it's gone (deleted, or hidden by the list source):
    /// pops it and anything pushed after it on iOS, clears the detail column on macOS.
    func clearSelection(after cocktail: Cocktail) {
        #if os(iOS)
        if let index = path.firstIndex(of: cocktail) {
            path.removeSubrange(index...)
        }
        #else
        if selectedCocktail == cocktail {
            selectedCocktail = nil
            preferredCompactColumn = .sidebar
        }
        #endif
    }

    #if os(iOS)
    /// Drops any pushed cocktail no longer in `viewModel.listOfAllDrinks` (deleted elsewhere).
    func pruneStalePathEntries() {
        let validIDs = Set(viewModel.listOfAllDrinks.map(\.id))
        path.removeAll { !validIDs.contains($0.id) }
    }
    #endif
}

#if DEBUG
#Preview {
    CocktailsView()
        .drinkoPreviewEnvironment()
}
#endif
