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
            Tab("Learn", systemImage: "books.vertical", value: .learn) {
                MacLearnView()
            }

            Tab("Cocktails", systemImage: "wineglass", value: .cocktails) {
                MacCocktailsView()
            }

            Tab("Cabinet", systemImage: "cabinet", value: .cabinet) {
                MacCabinetView()
            }

            Tab("Settings", systemImage: "gear", value: .settings) {
                MacSettingsView()
            }
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
