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
    @State private var isPresentingCustomCocktailSheet = false
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
            Group {
                if filterOption == .favoritesOnly && visibleCocktails.isEmpty {
                    ContentUnavailableView(
                        label: {
                            if viewModel.searchText.isEmpty {
                                Label("No favorite cocktails yet", systemImage: "heart.slash")
                            } else {
                                Label("No favorite cocktails found", systemImage: "heart.slash")
                            }
                        },
                        description: {
                            if viewModel.searchText.isEmpty {
                                Text("Add cocktails to favorites to quickly find them here.")
                            } else {
                                Text("No favorite cocktails match \"\(viewModel.searchText)\".")
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
                } else if viewModel.searchText.isEmpty {
                    List {
                        ForEach(visibleSectionKeys, id: \.self) { sectionKey in
                            Section {
                                ForEach(visibleGroupedCocktails[sectionKey] ?? []) { cocktail in
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
                } else if visibleCocktails.isEmpty {
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
                } else {
                    List(visibleCocktails) { cocktail in
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
            .sheet(isPresented: $isPresentingCustomCocktailSheet) {
                NavigationStack {
                    AddCustomCocktailView(
                        methodOptions: methodOptions,
                        glassOptions: glassOptions,
                        iceOptions: iceOptions,
                        unitOptions: unitOptions
                    )
                }
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
            isPresentingCustomCocktailSheet = true
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
