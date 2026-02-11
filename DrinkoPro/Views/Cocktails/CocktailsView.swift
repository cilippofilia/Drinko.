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

    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(Favorites.self) private var favorites
    @State private var filterOption: CocktailsViewModel.FilterOption = .all
    @State private var showCustomCocktailSheet = false
    @State private var showDeleteAlert: Bool = false
    @State private var cocktailPendingDeletion: Cocktail = .userCreatedExample

    @State var path = NavigationPath()

    #if os(iOS)
    var favoriteCocktailsTip = SwipeToFavoriteTip()
    #endif

    private var methodOptions: [String] {
        uniqueSorted(
            from: viewModel.listOfAllDrinks.map(\.method),
            fallback: ["shake & fine strain"]
        )
    }

    private var glassOptions: [String] {
        uniqueSorted(
            from: viewModel.listOfAllDrinks.map(\.glass),
            fallback: ["rock"]
        )
    }

    private var iceOptions: [String] {
        uniqueSorted(
            from: viewModel.listOfAllDrinks.map(\.ice),
            fallback: ["cubed"]
        )
    }

    private var unitOptions: [String] {
        uniqueSorted(
            from: viewModel.listOfAllDrinks
                .flatMap(\.ingredients)
                .map(\.unit),
            fallback: ["oz."]
        )
    }

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
    
    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .navigationTitle("Cocktails")
                .navigationDestination(for: Cocktail.self) { cocktail in
                    CocktailDetailView(cocktail: cocktail)
                }
                .searchable(text: searchBinding, prompt: "Search Cocktails")
                .toolbar {
                    #if os(iOS)
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        optionsMenu
                        addCocktailButton
                    }
                    #else
                    ToolbarItemGroup(placement: .automatic) {
                        optionsMenu
                        addCocktailButton
                    }
                    #endif
                }
                .sheet(isPresented: $showCustomCocktailSheet) {
                    NavigationStack {
                        AddCustomCocktailView(
                            methodOptions: methodOptions,
                            glassOptions: glassOptions,
                            iceOptions: iceOptions,
                            unitOptions: unitOptions
                        )
                    }
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
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
    }
}

private extension CocktailsView {
    func uniqueSorted(from values: [String], fallback: [String]) -> [String] {
        let cleaned = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let set = Set(cleaned + fallback)
        return set.sorted()
    }

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
    }

    var addCocktailButton: some View {
        Button {
            showCustomCocktailSheet = true
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
