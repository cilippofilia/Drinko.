//
//  MacContentView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 12/01/2026.
//

import SwiftUI

struct MacContentView: View {
    let selectedTab: NavigationTab

    var body: some View {
        Group {
            switch selectedTab {
            case .learn:
                LearnView()
            case .cocktails:
                Text("\(selectedTab.title) view")
            case .cabinet:
                Text("\(selectedTab.title) view")
            case .settings:
                Text("\(selectedTab.title) view")
            }
        }
    }
}

#Preview {
    MacContentView(selectedTab: .learn)
}
