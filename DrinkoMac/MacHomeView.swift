//
//  MacHomeView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 10/01/2026.
//

import PrivateAds
import SwiftData
import SwiftUI

struct MacHomeView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    @Environment(RemoveAdsStore.self) private var removeAdsStore
    // Same key as the iOS HomeView: remembers the last-used sidebar row between launches.
    @SceneStorage("selectedView") private var selectedView: String?

    // Cabinet categories, to move the selection off a deleted category's row.
    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) private var categories: [Category]

    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var interstitialAd: Ad?

    var body: some View {
        MacHomePageView(tab: appNavigationModel.selectedTab)
            .environment(\.macColumnVisibility, $columnVisibility)
            // Only restores while `selectedTab` is untouched, so it never clobbers a deep link
            // that selected a tab before this view appeared.
            .onAppear {
                if appNavigationModel.selectedTab == .learn, let selectedView,
                   let tab = AppTab(rawValue: selectedView) {
                    appNavigationModel.selectedTab = tab
                }
                fitSelection()
            }
            .onChange(of: appNavigationModel.selectedTab) { _, newValue in
                selectedView = newValue.rawValue
            }
            .onChange(of: categories.map(\.id)) {
                fitSelection()
            }
            .sheet(item: $interstitialAd) { ad in
                AdView(advert: ad, config: .crossPromo) {
                    CrossPromoRemoveAdsInfoView()
                }
            }
            .onChange(of: crossPromoSignal.count) { _, newValue in
                guard removeAdsStore.isAdsRemoved == false,
                      CrossPromoSignal.shouldShowInterstitial(at: newValue) else { return }
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

    /// Moves the selection off a Cabinet category that no longer exists (see `AppTab.fitted`).
    private func fitSelection() {
        let categoryIDs = Set(categories.map(\.id))
        appNavigationModel.selectedTab = appNavigationModel.selectedTab.fitted(
            isCompact: false,
            categoryIDs: categoryIDs
        )
    }
}

#if DEBUG
#Preview {
    MacHomeView()
        .drinkoPreviewEnvironment()
}
#endif
