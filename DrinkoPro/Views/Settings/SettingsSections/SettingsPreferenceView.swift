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
                openURL(URL(string: "app-settings:")!)
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
