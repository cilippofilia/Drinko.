//
//  CabinetDiscoveryView.swift
//  DrinkoPro
//

import SwiftData
import SwiftUI

/// Cocktails the Cabinet can make now, and ones it can make with one spirit swapped.
struct CabinetDiscoveryView: View {
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(LibraryLayout.discoveryStorageKey) private var layout: LibraryLayout = .list
    @Query private var items: [Item]
    /// Pushed here rather than as a `ToolsView.Selection`, so it works in every stack hosting this page.
    @State private var openedMatch: DiscoveryMatch?

    private static let cabinetOnlyNote: LocalizedStringKey =
        "Every ingredient has to be in your Cabinet, including juices, syrups and mixers."

    var body: some View {
        let stock = CabinetStock(bottles: items.map { ($0.name, $0.category?.name) })
        let result = CabinetDiscovery.discover(in: viewModel.listOfAllDrinks, stock: stock)

        Group {
            if items.isEmpty {
                ContentUnavailableView {
                    Label("Your Cabinet Is Empty", systemImage: "cabinet")
                } description: {
                    Text("Add the bottles you own to see what you can make.")
                } actions: {
                    Button("Go to Cabinet") { appNavigationModel.selectedTab = .cabinet }
                }
            } else if result.makeNow.isEmpty && result.twists.isEmpty {
                ContentUnavailableView {
                    Label("No Matches Yet", systemImage: "wineglass")
                } description: {
                    Text("Add a few more bottles to your Cabinet to unlock cocktails.")
                    Text(Self.cabinetOnlyNote)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        Text(Self.cabinetOnlyNote)
                            .foregroundStyle(.secondary)

                        DiscoverySection(id: "makeNow", title: String(localized: "Make Now"),
                                         matches: result.makeNow, layout: layout, onSelect: open)
                        DiscoverySection(id: "twists", title: String(localized: "Twists"),
                                         matches: result.twists, layout: layout, onSelect: open)
                    }
                    .padding([.horizontal, .bottom])
                    .animation(reduceMotion ? nil : .snappy, value: layout)
                }
                .toolbar {
                    ToolbarItem {
                        LibraryLayoutToggle(layout: $layout)
                    }
                }
            }
        }
        .navigationTitle("What Can I Make?")
        .navigationDestination(item: $openedMatch) { match in
            CocktailDetailView(cocktail: match.cocktail, swap: match.swap, showsLinkedCocktails: false)
        }
    }

    private func open(_ match: DiscoveryMatch) {
        openedMatch = match
    }
}

/// One group of matches, drawn like a Cocktails library section in the chosen layout.
private struct DiscoverySection: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    let id: String
    let title: String
    let matches: [DiscoveryMatch]
    let layout: LibraryLayout
    let onSelect: @MainActor (DiscoveryMatch) -> Void

    var body: some View {
        if !matches.isEmpty {
            LibrarySectionView(
                section: LibrarySection(id: id, title: title, items: matches),
                layout: layout,
                isCollapsed: false,
                isCollapsible: false,
                selection: nil,
                onToggleCollapsed: {},
                onSelect: onSelect,
                cardModel: cardModel,
                contextMenu: { _ in EmptyView() }
            )
        }
    }

    /// The cocktail's usual card, with the swap as its subtitle (shown in list rows).
    private func cardModel(for match: DiscoveryMatch) -> LibraryCardModel {
        var model = viewModel.cardModel(for: match.cocktail)
        model.subtitle = match.swap?.message
        return model
    }
}
