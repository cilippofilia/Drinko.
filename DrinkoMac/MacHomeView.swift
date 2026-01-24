//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 10/01/2026.
//

import SwiftUI

struct MacHomeView: View {
    @State private var selectedTab: NavigationTab? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedTab) {
                ForEach(NavigationTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.systemImage)
                        .tag(tab)
                }
            }
        } detail: {
            switch selectedTab {
            case .learn:
                NavigationStack {
                    LearnView()
                }
            case .cocktails:
                NavigationStack {
                    CocktailsView()
                }
            case .cabinet:
                NavigationStack {
                    MacCabinetView()
                }
            case .settings:
                NavigationStack {
                    MacSettingsView()
                }
            case nil:
                ContentUnavailableView(
                    "Ready to Mix?",
                    systemImage: "wineglass",
                    description: Text("Choose a section from the sidebar to start your mixology journey.")
                )
            }
        }
    }
}

#Preview {
    MacHomeView()
}
