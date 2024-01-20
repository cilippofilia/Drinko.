//
//  SettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct SettingsView: View {
    static let settingsTag: String? = "Settings"

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
    }
}

#Preview {
    SettingsView()
}


