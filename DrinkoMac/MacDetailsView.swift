//
//  MacDetailsView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 12/01/2026.
//

import SwiftUI

struct MacDetailsView: View {
    let selectedTab: NavigationTab
    var body: some View {
        Group {
            switch selectedTab {
            case .learn:
                Text("\(selectedTab.title) details view")
            case .cocktails:
                Text("\(selectedTab.title) details view")
            case .cabinet:
                Text("\(selectedTab.title) details view")
            case .settings:
                Text("\(selectedTab.title) details view")
            }
        }
    }
}

#Preview {
    MacDetailsView(selectedTab: .learn)
}
