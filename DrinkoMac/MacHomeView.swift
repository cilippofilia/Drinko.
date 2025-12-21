//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 16/12/2025.
//

import StoreKit
import SwiftUI

struct MacHomeView: View {
    @Environment(MacTabViewModel.self) private var tabViewModel

    var body: some View {
        @Bindable var tabVM = tabViewModel
        TabView(selection: $tabVM.selectedTab) {
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: MacTab.learn.rawValue)
                }
                .tag(MacTab.learn)
            Text("Replace with MacCocktailsView")
                .tabItem {
                    Label("Cocktails", systemImage: MacTab.cocktails.rawValue)
                }
                .tag(MacTab.cocktails)
            Text("Replace with MacCabinetView")
                .tabItem {
                    Label("Cabinet", systemImage: MacTab.cabinet.rawValue)
                }
                .tag(MacTab.cabinet)
            Text("Replace with MacSettingsView")
                .tabItem {
                    Label("Settings", systemImage: MacTab.settings.rawValue)
                }
                .tag(MacTab.settings)
        }
    }
}

@Observable
class MacTabViewModel {
    var selectedTab: MacTab = .learn
}

enum MacTab: String, CaseIterable {
    case learn = "books.vertical"
    case cocktails = "wineglass"
    case cabinet = "cabinet"
    case settings = "gear"
}

#Preview {
    MacHomeView()
}
