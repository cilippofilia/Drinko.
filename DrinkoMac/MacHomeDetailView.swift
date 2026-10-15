//
//  MacHomeDetailView.swift
//  DrinkoMac
//

import SwiftUI

/// The page for the sidebar row selected in `MacHomeView`.
struct MacHomeDetailView: View {
    let tab: AppTab

    var body: some View {
        page
            // The pages seed their state from their init arguments, so moving between two rows
            // of the same kind has to recreate them.
            .id(tab)
    }

    @ViewBuilder
    private var page: some View {
        switch tab {
        case .learn:
            NavigationStack {
                LearnView()
            }
        case .learnSection(let id):
            NavigationStack {
                LearnView(sectionID: id)
            }
        case .cabinet:
            // Has its own NavigationStack.
            MacCabinetView()
        case .cabinetCategory(let id):
            MacCabinetView(categoryID: id)
        case .cocktails:
            NavigationStack {
                CocktailsView()
            }
        case .cocktailFilter(let filter):
            NavigationStack {
                CocktailsView(filter: filter)
            }
        case .tools:
            NavigationStack {
                ToolsView()
            }
        case .tool(let item):
            NavigationStack {
                ToolsDetailView(selection: item)
                    .crossPromoBanner()
            }
        case .settings:
            NavigationStack {
                MacSettingsView()
            }
        }
    }
}
