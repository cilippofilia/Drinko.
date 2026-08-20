//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 10/01/2026.
//

import PrivateAds
import SwiftUI

struct MacHomeView: View {
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var selectedTab: NavigationTab? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var interstitialAd: Ad?

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedTab) {
                ForEach(NavigationTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.systemImage)
                        .tag(tab)
                }
            }
            .navigationSplitViewColumnWidth(
                min: 140,
                ideal: 180,
                max: 220
            )
        } detail: {
            switch selectedTab {
            case .learn:
                NavigationStack {
                    LearnView()
                }
            case .cocktails:
                NavigationStack {
                    CocktailsView()
                }
            case .cabinet:
                NavigationStack {
                    MacCabinetView()
                }
            case .settings:
                NavigationStack {
                    MacSettingsView()
                }
            case nil:
                ContentUnavailableView(
                    "Ready to Mix?",
                    systemImage: "wineglass",
                    description: Text("Choose a section from the sidebar to start your mixology journey.")
                )
            }
        }
        .sheet(item: $interstitialAd) { ad in
            AdView(advert: ad, config: .crossPromo) {
                CrossPromoRemoveAdsInfoView()
            }
        }
        .onChange(of: crossPromoSignal.count) { _, newValue in
            guard removeAdsStore.isAdsRemoved == false, newValue > 0, newValue.isMultiple(of: 3) else { return }
            Task { await refreshInterstitialAd() }
        }
        // Dismiss an ad the user is mid-way through if they buy "Remove Ads" from its own paywall.
        .onChange(of: removeAdsStore.isAdsRemoved) { _, isAdsRemoved in
            guard isAdsRemoved else { return }
            interstitialAd = nil
        }
    }

    private func refreshInterstitialAd() async {
        guard removeAdsStore.isAdsRemoved == false else { return }
        guard let url = AdConfiguration.crossPromo.adsJSONURL else { return }
        interstitialAd = try? await AdStore.fetchRandomAd(
            from: url,
            excludedIDs: AdConfiguration.crossPromo.excludedIDs
        )
    }
}

#if DEBUG
#Preview {
    MacHomeView()
        .drinkoPreviewEnvironment()
}
#endif
