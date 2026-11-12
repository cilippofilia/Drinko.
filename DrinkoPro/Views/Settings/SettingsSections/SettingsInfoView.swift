//
//  SettingsInfoView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import AboutSection
import SwiftUI

struct SettingsInfoView: View {
    #if os(iOS)
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var showRemoveAdsPaywall = false
    #endif

    var body: some View {
        Section {
            NavigationLink(destination: ReadMeView()) {
                SettingsRowView(
                    icon: "r.circle",
                    color: .secondary,
                    itemName: "Read me"
                )
            }

            ChangelogRow()

            #if os(iOS)
            WidgetGuideRow()

            Button {
                showRemoveAdsPaywall = true
            } label: {
                SettingsRowView(
                    icon: removeAdsStore.isAdsRemoved ? "checkmark.seal.fill" : "nosign",
                    color: .secondary,
                    itemName: removeAdsStore.isAdsRemoved ? "Ads Removed" : "Remove Ads"
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showRemoveAdsPaywall) {
                CrossPromoRemoveAdsInfoView()
                    .presentationDetents([.medium])
            }
            #endif

            ShareRow(info: drinkoAppInfo)
        } header: {
            Text("Info")
                .foregroundStyle(.secondary)
        } footer: {
            VStack(alignment: .leading) {
                VersionFooter(info: drinkoAppInfo)
                #if DEBUG
                ContentSourceFooter()
                #endif
            }
            .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
    }
}

#if DEBUG
#Preview {
    Form {
        SettingsInfoView()
    }
    .drinkoPreviewEnvironment()
}
#endif
