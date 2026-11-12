//
//  SettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import AboutSection
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                SettingsPreferenceView()

                SettingsContactsView()

                SettingsInfoView()
            }
            .navigationTitle("Settings")
            .aboutDestinations(info: drinkoAppInfo, releases: drinkoReleases, widgetGuide: drinkoWidgetGuide) {
                WidgetGuideArtwork()
            }
            .scrollBounceBehavior(.basedOnSize)
            #if os(iOS)
            .crossPromoBanner()
            #endif
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .environment(Favorites())
        .environment(RemoveAdsStore())
}
#endif
