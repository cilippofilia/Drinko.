//
//  MacHomePageView.swift
//  DrinkoMac
//

import SwiftUI

/// The page for the sidebar row selected in `MacHomeView`, sidebar included.
///
/// Each page is one split view with `MacSidebarView` as its first column: Learn, Cocktails
/// and Tools add their library and detail columns (see `LibraryNavigationContainer`), and
/// the other pages fill a single detail column. A split view nested in another one's detail
/// column gets the outer sidebar's width added to its leading safe area twice on macOS,
/// which pushes the detail content to the trailing edge, so the window never nests them.
struct MacHomePageView: View {
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
            LearnView()
        case .learnSection(let id):
            LearnView(sectionID: id)
        case .cocktails:
            CocktailsView()
        case .cocktailFilter(let filter):
            CocktailsView(filter: filter)
        case .tools:
            ToolsView()
        case .cabinet:
            MacSinglePageView {
                // Has its own NavigationStack.
                MacCabinetView()
            }
        case .cabinetCategory(let id):
            MacSinglePageView {
                MacCabinetView(categoryID: id)
            }
        case .tool(let item):
            MacSinglePageView {
                NavigationStack {
                    ToolsDetailView(selection: item)
                        .crossPromoBanner()
                }
            }
        case .settings:
            MacSinglePageView {
                NavigationStack {
                    MacSettingsView()
                }
            }
        }
    }
}
