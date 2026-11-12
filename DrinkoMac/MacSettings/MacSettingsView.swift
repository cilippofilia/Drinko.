//
//  MacSettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import AboutSection
import SwiftUI

struct MacSettingsView: View {
    @Environment(\.openURL) var openURL

    @AppStorage(CocktailListSource.storageKey) private var listSource: CocktailListSource = .userAndApp
    @AppStorage(CocktailUnitPreference.storageKey) private var unitPreference: CocktailUnitPreference = .automatic

    var body: some View {
        let languageCode = Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN"

        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        Text(languageCode)
                            .foregroundStyle(.secondary)
                            .padding(.trailing)
                    } label: {
                        Button {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.Localization-Settings") {
                                openURL(url)
                            }
                        } label: {
                            MacSettingsRowView(icon: "character.bubble", color: .primary, itemName: "Language")
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens macOS language settings.")
                    }

                    Picker(selection: $listSource) {
                        ForEach(CocktailListSource.allCases) { source in
                            Text(source.title)
                                .tag(source)
                        }
                    } label: {
                        MacSettingsRowView(icon: "list.bullet", color: .primary, itemName: "Cocktail List")
                    }
                    .accessibilityHint("Chooses which cocktails appear in the Cocktails list.")

                    Picker(selection: $unitPreference) {
                        ForEach(CocktailUnitPreference.allCases) { preference in
                            Text(preference.title)
                                .tag(preference)
                        }
                    } label: {
                        MacSettingsRowView(icon: "ruler", color: .primary, itemName: "Units")
                    }
                    .accessibilityHint("Chooses whether cocktail recipes show milliliters or ounces.")
                } header: {
                    Text("Preferences")
                        .foregroundStyle(.secondary)
                }

                Section {
                    ContactRow(info: drinkoAppInfo)
                    SuggestFeatureRow(info: drinkoAppInfo)
                    RateRow(info: drinkoAppInfo)
                } header: {
                    Text("Support")
                        .foregroundStyle(.secondary)
                }

                MacSettingsInfoView()
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .aboutDestinations(info: drinkoAppInfo, releases: drinkoReleases, widgetGuide: drinkoWidgetGuide) {
                WidgetGuideArtwork()
            }
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
        }
    }

}

#if DEBUG
#Preview {
    MacSettingsView()
        .environment(Favorites())
        .environment(RemoveAdsStore())
}
#endif
