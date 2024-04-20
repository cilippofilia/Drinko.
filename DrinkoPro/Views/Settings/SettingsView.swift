//
//  SettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct SettingsView: View {
    static let settingsTag: String? = "Settings"
    @Environment(DrinkoIcons.self) var icons: DrinkoIcons

    var body: some View {
        NavigationStack {
            Form {
                SettingsPreferenceView()

                SettingsContactsView()

                SettingsInfoView()
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
    }
}

#Preview {
    SettingsView()
        .environment(DrinkoIcons())
}


