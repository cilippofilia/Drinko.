//
//  SettingsInfoView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsInfoView: View {
    #if os(iOS)
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var showRemoveAdsPaywall = false
    #endif

    var body: some View {
        Section(
            header: Text("Info").foregroundStyle(.secondary)
        ) {
            NavigationLink(destination: ReadMeView()) {
                SettingsRowView(
                    icon: "r.circle",
                    color: .secondary,
                    itemName: "Read me"
                )
            }

            #if os(iOS)
            NavigationLink(destination: WidgetTutorialView()) {
                SettingsRowView(
                    icon: "widget.small.badge.plus",
                    color: .secondary,
                    itemName: "Add a Widget"
                )
            }

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

            ShareLink(item: drinkoURL!) {
                SettingsRowView(
                    icon: "square.and.arrow.up",
                    color: .secondary,
                    itemName: "Share the app"
                )
            }

            HStack {
                SettingsRowView(
                    icon: "v.circle",
                    color: .secondary,
                    itemName: "Version"
                )
                Spacer()

                Text("\(getCurrentAppVersion())")
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Version")
            .accessibilityValue(getCurrentAppVersion())
        }
        .foregroundStyle(.primary)
    }

    // Get current Version of the App function
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }
}

#if DEBUG
#Preview {
    Form {
        SettingsInfoView()
    }
}
#endif
