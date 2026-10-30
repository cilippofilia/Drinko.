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
    @Query private var items: [Item]

    private static let staplesNote: LocalizedStringKey =
        "Assumes you have juices, syrups, mixers and fresh ingredients. Only bottles in your Cabinet are checked."

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
                    Text(Self.staplesNote)
                }
            } else {
                List {
                    Section {
                    } header: {
                        Text(Self.staplesNote)
                            .textCase(nil)
                    }

                    DiscoverySection(title: "Make Now", matches: result.makeNow)
                    DiscoverySection(title: "Twists", matches: result.twists)
                }
            }
        }
        .navigationTitle("What Can I Make?")
    }
}

private struct DiscoverySection: View {
    let title: LocalizedStringKey
    let matches: [DiscoveryMatch]

    var body: some View {
        if !matches.isEmpty {
            Section(title) {
                ForEach(matches) { match in
                    NavigationLink(value: ToolsView.Selection.discoveredCocktail(match)) {
                        DiscoveryMatchRow(match: match)
                    }
                }
            }
        }
    }
}
