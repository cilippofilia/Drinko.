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

    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    @Environment(\.modelContext) private var modelContext

    @State private var filterOption: CocktailsViewModel.FilterOption = .all
    @State private var showCreateCocktailSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var cocktailPendingDeletion: Cocktail = .userCreatedExample
    @State private var didConfigureModelContext: Bool = false

    @State var path = NavigationPath()

    private var visibleCocktails: [Cocktail] {
        viewModel.filteredCocktails(filterOption: filterOption) { cocktail in
            favorites.contains(cocktail)
        }
    }

    private var visibleGroupedCocktails: [String: [Cocktail]] {
        viewModel.groupedCocktails(filterOption: filterOption) { cocktail in
            favorites.contains(cocktail)
        }
    }

    private var visibleSectionKeys: [String] {
        viewModel.sortedSectionKeys(filterOption: filterOption) { cocktail in
            favorites.contains(cocktail)
        }
    }

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarTrailing
        #else
        return .automatic
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .navigationTitle("Cocktails")
                .navigationDestination(for: Cocktail.self) { cocktail in
                    CocktailDetailView(cocktail: cocktail)
                }
                .searchable(text: searchBinding, prompt: "Search Cocktails")
                .toolbar {
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
                }
        }
    }
}

private extension CocktailsView {
    var contentView: some View {
        Group {
            if shouldShowFilterEmptyState {
                filterEmptyStateView
            } else if viewModel.searchText.isEmpty {
                fullListView
            } else if visibleCocktails.isEmpty {
                searchEmptyStateView
            } else {
                filteredListView
            }
        }
        .accessibilityLabel("Filter cocktails")
    }

    var shouldShowFilterEmptyState: Bool {
        (filterOption == .favoritesOnly || filterOption == .userCreatedOnly) && visibleCocktails.isEmpty
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
                } else if filterOption == .userCreatedOnly && viewModel.searchText.isEmpty {
                    Label("No custom cocktails yet", systemImage: "plus.circle")
                } else {
                    Label("No cocktails found", systemImage: "exclamationmark.magnifyingglass")
                }
            },
            description: {
                if filterOption == .favoritesOnly && viewModel.searchText.isEmpty {
                    Text("Add cocktails to favorites to quickly find them here.")
                } else if filterOption == .userCreatedOnly && viewModel.searchText.isEmpty {
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

    var fullListView: some View {
        List {
            ForEach(visibleSectionKeys, id: \.self) { sectionKey in
                Section {
                    ForEach(visibleGroupedCocktails[sectionKey] ?? []) { cocktail in
                        cocktailRow(for: cocktail)
                    }
                } header: {
                    Text(sectionKey)
                }
            }
        }
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

    var filteredListView: some View {
        List(visibleCocktails) { cocktail in
            cocktailRow(for: cocktail)
        }
    }

    func cocktailRow(for cocktail: Cocktail) -> some View {
        NavigationLink(value: cocktail) {
            CocktailRowView(cocktail: cocktail)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    FavoriteCocktailButtonView(cocktail: cocktail)
                        .tint(favorites.contains(cocktail) ? .red : .blue)
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
        }
    }

    var optionsMenu: some View {
        Menu {
            Section("Filter") {
                Button {
                    filterOption = .all
                } label: {
                    HStack {
                        Text("All Cocktails")
                        if filterOption == .all {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                Button {
                    filterOption = .cocktailsOnly
                } label: {
                    HStack {
                        Text("Cocktails Only")
                        if filterOption == .cocktailsOnly {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                Button {
                    filterOption = .shotsOnly
                } label: {
                    HStack {
                        Text("Shots Only")
                        if filterOption == .shotsOnly {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                Button {
                    filterOption = .favoritesOnly
                } label: {
                    HStack {
                        Text("Favorites Only")
                        if filterOption == .favoritesOnly {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                Button {
                    filterOption = .userCreatedOnly
                } label: {
                    HStack {
                        Text("User Created Only")
                        if filterOption == .userCreatedOnly {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

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
}

#if DEBUG
#Preview {
    NavigationStack {
        CocktailsView()
            .environment(CocktailsViewModel())
            .environment(Favorites())
    }
}
#endif
