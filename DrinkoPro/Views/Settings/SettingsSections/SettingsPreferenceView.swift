//
//  SettingsPreferenceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsPreferenceView: View {
    @AppStorage(CocktailListSource.storageKey) private var listSource: CocktailListSource = .userAndApp

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

            Picker(selection: $listSource) {
                ForEach(CocktailListSource.allCases) { source in
                    Text(source.title)
                        .tag(source)
                }
            } label: {
                SettingsRowView(
                    icon: "list.bullet",
                    color: .secondary,
                    itemName: "Cocktail List"
                )
            }
            #if os(iOS)
            .pickerStyle(.navigationLink)
            #endif
            .accessibilityHint("Chooses which cocktails appear in the Cocktails list.")
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
