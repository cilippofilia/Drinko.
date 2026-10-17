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
    /// A fixed filter for this page (a sidebar row). `nil` lets the user pick one.
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
    @AppStorage(CollapsedSections.cocktailsStorageKey) private var collapsedSections = CollapsedSections()

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

    private var pageTab: AppTab {
        presetFilter.map(AppTab.cocktailFilter) ?? .cocktails
    }

    private var visibleSections: [LibrarySection<Cocktail>] {
        viewModel.librarySections(filterOption: filterOption, source: listSource) { cocktail in
            favorites.contains(cocktail)
        }
    }

    /// Limited to the list source. A sidebar filter page (other than All) shows no band, since
    /// unfiltered recents would sit above a filtered list.
    private var recentCocktails: [Cocktail] {
        guard presetFilter == nil || presetFilter == .all else { return [] }
        return viewModel.recentCocktailsWithPictures(from: recentsStore.ids(in: .cocktails))
            .filter(listSource.includes)
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

    private var navigation: LibraryNavigationBindings<Cocktail> {
        #if os(iOS)
        .init(path: $path)
        #else
        .init(selection: $selectedCocktail, preferredCompactColumn: $preferredCompactColumn)
        #endif
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        LibraryNavigationContainer(
            navigation: navigation,
            library: {
                CocktailsLibraryContent(
                    title: title,
                    recents: recentCocktails,
                    sections: visibleSections,
                    selection: currentCocktail,
                    presetFilter: presetFilter,
                    filterOption: $filterOption,
                    listSource: listSource,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    onSelect: select,
                    onRequestDelete: { cocktail in
                        cocktailPendingDeletion = cocktail
                        showDeleteAlert = true
                    }
                )
                .navigationTitle(title)
                .searchable(text: $viewModel.searchText, prompt: "Cocktails or Ingredients")
                .toolbar {
                    ToolbarItem(placement: layoutTogglePlacement) {
                        LibraryLayoutToggle(layout: $layout)
                    }
                    ToolbarItemGroup(placement: toolbarPlacement) {
                        CocktailsOptionsMenu(
                            filterOption: $filterOption,
                            presetFilter: presetFilter,
                            availableOptions: availableFilterOptions
                        )
                        Button("Create Cocktail", systemImage: "plus") {
                            showCreateCocktailSheet = true
                        }
                    }
                }
                #if os(iOS) || os(macOS)
                .crossPromoBanner()
                #endif
            },
            detail: { CocktailDetailView(cocktail: $0) },
            placeholder: {
                ContentUnavailableView(
                    "Select a Cocktail",
                    systemImage: "wineglass",
                    description: Text("Choose a cocktail to see its details.")
                )
            }
        )
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
        // `initial: true` covers a page created by the tab switch the request itself made.
        .onChange(of: appNavigationModel.pendingCreation, initial: true) { _, _ in
            presentPendingCreationIfNeeded()
        }
        .onChange(of: listSource) { _, _ in
            // Drop a filter or selection the new source can no longer show. A preset
            // filter stays, and its page shows an empty state instead.
            if presetFilter == nil, !availableFilterOptions.contains(filterOption) {
                filterOption = .all
            }
            if let currentCocktail, !listSource.includes(currentCocktail) {
                clearSelection(after: currentCocktail)
            }
        }
        // Catches a user cocktail deleted from another live Cocktails page (iPad).
        #if os(iOS)
        .onChange(of: viewModel.userCocktails.map(\.id)) { _, _ in pruneStalePathEntries() }
        .onAppear(perform: pruneStalePathEntries)
        #endif
        .task(id: currentCocktail?.id) {
            // Record only once the selection settles; a new selection cancels this.
            guard let id = currentCocktail?.id else { return }
            try? await Task.sleep(for: RecentsStore.recordDelay)
            guard !Task.isCancelled else { return }
            recentsStore.record(id, in: .cocktails)
        }
    }
}

private extension CocktailsView {

    @MainActor
    func openPendingCocktailIfNeeded() {
        // Only the main Cocktails page opens deep links; a sidebar filter page that has been
        // opened before stays loaded and must not consume the link.
        guard presetFilter == nil else { return }
        guard let cocktailID = appNavigationModel.consumePendingCocktailID() else { return }
        guard let cocktail = viewModel.listOfAllDrinks.first(where: { $0.id == cocktailID }) else { return }

        select(cocktail)
    }

    /// Presents the create sheet for File › New Cocktail. Only the selected page responds;
    /// other Cocktails pages opened before stay loaded and must not consume the request.
    @MainActor
    func presentPendingCreationIfNeeded() {
        guard appNavigationModel.selectedTab == pageTab else { return }
        guard appNavigationModel.consumePendingCreation(.cocktail) else { return }
        showCreateCocktailSheet = true
    }

    /// Recorded as recent once the selection settles (see the `.task(id:)` in `body`).
    func select(_ cocktail: Cocktail) {
        #if os(iOS)
        path = [cocktail]
        #else
        selectedCocktail = cocktail
        preferredCompactColumn = .detail
        #endif
    }

    /// Stops showing `cocktail` once it's deleted or hidden by the list source.
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
    /// Pops the first pushed cocktail deleted elsewhere, and every page pushed after it.
    func pruneStalePathEntries() {
        let validIDs = Set(viewModel.listOfAllDrinks.map(\.id))
        if let index = path.firstIndex(where: { !validIDs.contains($0.id) }) {
            path.removeSubrange(index...)
        }
    }
    #endif
}

#if DEBUG
#Preview {
    CocktailsView()
        .drinkoPreviewEnvironment()
}
#endif
