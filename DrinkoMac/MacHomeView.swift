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
            columnVisibility: .constant(.all),
            sidebar: {
                List(selection: $selectedTab) {
                    ForEach(NavigationTab.allCases) { tab in
                        Label(tab.title, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
            },
            content: {
                if let selectedTab = selectedTab {
                    Text("\(selectedTab.title) Content")
                }
            },
            detail: {
                if let selectedTab = selectedTab {
                    Text("\(selectedTab.title) Content Detail")
                }
            }
        )
    }
}

#Preview {
    MacHomeView()
}
