//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import PrivateAds
import StoreKit
import SwiftUI

struct HomeView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    @Environment(RemoveAdsStore.self) private var removeAdsStore
    // AppStorage is used to keep track of how many times the app has been opened
    @AppStorage("appUsageCounter") var appUsageCounter: Int = 0
    // AppStorage flag so the widget tutorial sheet only ever auto-presents once
    @AppStorage("widgetTutorialShown") var widgetTutorialShown: Bool = false
    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?
    @Environment(\.requestReview) private var requestReview

    @State private var showingWidgetTutorial = false
    @State private var interstitialAd: Ad?

    var body: some View {
        TabView(selection: selectedViewBinding) {
            Tab("Learn", systemImage: "books.vertical", value: LearnView.learnTag) {
                NavigationStack {
                    LearnView()
                }
            }
            Tab("Cocktails", systemImage: "wineglass", value: CocktailsView.cocktailsTag) {
                CocktailsView()
            }
            Tab("Cabinet", systemImage: "cabinet", value: CabinetView.cabinetTag) {
                CabinetView()
            }
            Tab("Settings", systemImage: "gear", value: SettingsView.settingsTag) {
                SettingsView()
            }
        }
        .onAppear(perform: checkForReview)
        .sheet(isPresented: $showingWidgetTutorial) {
            NavigationStack {
                WidgetTutorialView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingWidgetTutorial = false
                            }
                        }
                    }
            }
        }
        // A PrivateAds cross-promo ad every 3rd interaction bump (favoriting a cocktail or
        // product, creating a user cocktail, or adding a cabinet category — see
        // `CrossPromoSignal`). Lives here rather than on any one tab since the triggering
        // action can happen from Cocktails or Cabinet; `.fullScreenCover` presents over the
        // whole window regardless of which tab is active. Fetched directly (rather than via
        // PrivateAds's own `.showAd(when:)`) so a failed fetch can't get the trigger stuck.
        .fullScreenCover(item: $interstitialAd) { ad in
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

    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }

    func checkForReview() {
        appUsageCounter += 1

        if appUsageCounter == 3 || appUsageCounter % 15 == 0 {
            if appUsageCounter > 103 { appUsageCounter = 0 }
            requestReview()
        }

        // Show the widget tutorial once, after the user has had a few app
        // opens. The threshold of 4 avoids overlapping with the review
        // prompt at 3, and `>=` ensures users already past 4 still see it.
        if appUsageCounter >= 4 && !widgetTutorialShown {
            widgetTutorialShown = true
            showingWidgetTutorial = true
        }
    }

    private var selectedViewBinding: Binding<String?> {
        Binding(
            get: {
                appNavigationModel.selectedTab ?? selectedView
            },
            set: { newValue in
                selectedView = newValue
                appNavigationModel.selectedTab = newValue
            }
        )
    }
}

#if DEBUG
#Preview {
    HomeView()
        .drinkoPreviewEnvironment()
}
#endif
