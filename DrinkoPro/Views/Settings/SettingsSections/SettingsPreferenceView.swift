//
//  SettingsPreferenceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsPreferenceView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) var openURL

    var body: some View {
        Section("Preferences") {
            Button {
                if let settingsURL = URL(string: "app-settings:") {
                    openURL(settingsURL)
                }
            } label: {
                SettingsRowView(
                    icon: "character.bubble",
                    color: .secondary,
                    itemName: "Language"
                )
                .badge(
                    Text(Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN")
                        .foregroundStyle(.secondary)
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens system language settings.")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        SettingsPreferenceView()
    }
}
#endif
