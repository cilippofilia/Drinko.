//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 10/01/2026.
//

import SwiftUI

struct MacHomeView: View {
    @State private var selectedTab: NavigationTab? = nil

    var body: some View {
        NavigationSplitView(
            columnVisibility: .constant(.automatic),
            sidebar: {
                List(selection: $selectedTab) {
                    ForEach(NavigationTab.allCases) { tab in
                        Label(tab.title, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
            },
            detail: {
                if let selectedTab = selectedTab {
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
                            CabinetView()
                        }
                    case .settings:
                        NavigationStack {
                            Text("SETTINGS VIEW")
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    MacHomeView()
}
