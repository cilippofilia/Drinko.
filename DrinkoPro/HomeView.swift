//
//  HomeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import PrivateAds
import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    @Environment(RemoveAdsStore.self) private var removeAdsStore
    // SceneStorage is used to keep track of what tab was last used before closing the app
    @SceneStorage("selectedView") var selectedView: String?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Cabinet categories, for the iPad sidebar's Cabinet group (same order as CabinetView).
    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) private var categories: [Category]

    @State private var interstitialAd: Ad?

    var body: some View {
        @Bindable var appNavigationModel = appNavigationModel

        TabView(selection: $appNavigationModel.selectedTab) {
            Tab("Learn", systemImage: "books.vertical", value: AppTab.learn) {
                LearnView()
            }
            Tab("Cabinet", systemImage: "cabinet", value: AppTab.cabinet) {
                CabinetView()
            }
            Tab("Cocktails", systemImage: "wineglass", value: AppTab.cocktails) {
                CocktailsView()
            }
            Tab("Tools", systemImage: "wrench.and.screwdriver", value: AppTab.tools) {
                ToolsView()
            }
            Tab("Settings", systemImage: "gear", value: AppTab.settings) {
                SettingsView()
            }

            // The sidebar-only groups below only make sense once there's a sidebar to put them
            // in. In a compact (bottom tab bar) layout they'd otherwise all count toward the
            // tab bar, pushing the real tabs into an unwanted "More" overflow page.
            if horizontalSizeClass != .compact {
                // `.sidebarOnly` on the rows alone doesn't hide a section: it would still show up in
                // the floating tab bar as an extra item after Settings.
                TabSection("Cocktails") {
                    ForEach(AppTab.sidebarCocktailFilters, id: \.self) { filter in
                        Tab(filter.pageTitle, systemImage: filter.sidebarSymbol, value: AppTab.cocktailFilter(filter)) {
                            CocktailsView(filter: filter)
                        }
                        .tabPlacement(.sidebarOnly)
                    }
                }
                .tabPlacement(.sidebarOnly)
                TabSection("Learn") {
                    ForEach(LessonsViewModel.librarySectionIDs, id: \.self) { id in
                        Tab(
                            LessonsViewModel.sectionTitle(for: id) ?? "",
                            systemImage: id == LessonsViewModel.booksSectionID ? "books.vertical" : "book",
                            value: AppTab.learnSection(id)
                        ) {
                            LearnView(sectionID: id)
                        }
                        .tabPlacement(.sidebarOnly)
                    }
                }
                .tabPlacement(.sidebarOnly)
                TabSection("Tools") {
                    ForEach(ToolsLibrary.calculatorItems) { item in
                        Tab(
                            ToolsLibrary.cardModel(for: item).title,
                            systemImage: ToolsLibrary.sidebarSymbol(for: item),
                            value: AppTab.tool(item)
                        ) {
                            NavigationStack {
                                ToolsDetailView(selection: item)
                                    .crossPromoBanner()
                            }
                        }
                        .tabPlacement(.sidebarOnly)
                    }
                }
                .tabPlacement(.sidebarOnly)
                TabSection("Cabinet") {
                    ForEach(categories) { category in
                        Tab(category.name, systemImage: "tray", value: AppTab.cabinetCategory(category.id)) {
                            CabinetView(categoryID: category.id)
                        }
                        .tabPlacement(.sidebarOnly)
                    }
                }
                .tabPlacement(.sidebarOnly)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        // Restore the last-used tab from the previous session. Only applies while
        // `selectedTab` is still at its untouched default, so it never clobbers a deep link
        // (`AppNavigationModel.handle(url:)`) that already selected a tab before this view
        // first appeared.
        .onAppear {
            if appNavigationModel.selectedTab == .learn, let selectedView, let tab = AppTab(rawValue: selectedView) {
                appNavigationModel.selectedTab = tab
            }
            fitSelection()
        }
        .onChange(of: appNavigationModel.selectedTab) { _, newValue in
            selectedView = newValue.rawValue
        }
        .onChange(of: horizontalSizeClass) {
            fitSelection()
        }
        // A selected Cabinet category row disappears when the category is deleted.
        .onChange(of: categories.map(\.id)) {
            fitSelection()
        }
        // A PrivateAds cross-promo ad every 5th interaction bump (favoriting a cocktail or
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

    /// Moves the selection to something the current layout can show (see `AppTab.fitted`).
    private func fitSelection() {
        let fitted = appNavigationModel.selectedTab.fitted(
            isCompact: horizontalSizeClass == .compact,
            categoryIDs: Set(categories.map(\.id))
        )
        if fitted != appNavigationModel.selectedTab {
            appNavigationModel.selectedTab = fitted
        }
    }

    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
}

#if DEBUG
#Preview {
    HomeView()
        .drinkoPreviewEnvironment()
}
#endif
