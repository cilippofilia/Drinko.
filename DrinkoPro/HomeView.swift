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
    @Environment(LessonsViewModel.self) private var lessonsViewModel
    @SceneStorage("selectedView") var selectedView: String?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Cabinet categories, for the sidebar's Cabinet group (same order as CabinetView).
    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) private var categories: [Category]

    @State private var interstitialAd: Ad?
    @State private var showRemoveAdsPaywall = false
    /// The sidebar row `fitSelection()` last swapped for its main tab because the layout
    /// couldn't show it (compact width, or a category not synced yet). It comes back once it
    /// can be shown, and stays the saved tab meanwhile.
    @State private var hiddenSelection: AppTab?

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

            // In the compact tab bar these groups would count as tabs and push the real ones into
            // a "More" page.
            if AppTab.sidebarRowsAvailable(horizontalSizeClass: horizontalSizeClass) {
                // `.sidebarOnly` on the rows alone doesn't hide a section: it would still show up in
                // the floating tab bar as an extra item after Settings.
                TabSection("Cocktails") {
                    ForEach(AppTab.sidebarCocktailFilters, id: \.self) { filter in
                        Tab(filter.sidebarTitle, systemImage: filter.sidebarSymbol, value: AppTab.cocktailFilter(filter)) {
                            CocktailsView(filter: filter)
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
                TabSection("Learn") {
                    ForEach(lessonsViewModel.librarySectionIDs, id: \.self) { id in
                        Tab(
                            lessonsViewModel.sectionTitle(for: id) ?? "",
                            systemImage: lessonsViewModel.sidebarSymbol(for: id),
                            value: AppTab.learnSection(id)
                        ) {
                            LearnView(sectionID: id)
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
        // On iOS 27+, asks for a sidebar at regular width (iPhone Duo's inner display); iPad keeps
        // its default presentation.
        .drinkoTabBarPlacement()
        // Only ever visible with a sidebar; the compact tab bar has nowhere to show it.
        .tabViewSidebarBottomBar {
            if removeAdsStore.isAdsRemoved == false {
                // Insets match the system sidebar rows (icon at 35pt, title at 70pt) so this
                // reads as one more row rather than a toolbar button.
                Button {
                    showRemoveAdsPaywall = true
                } label: {
                    HStack(spacing: 13) {
                        Image(systemName: "nosign")
                            .foregroundStyle(.red)
                            .frame(width: 22)
                        Text("Remove Ads")
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .padding(.leading, 35)
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showRemoveAdsPaywall) {
            CrossPromoRemoveAdsInfoView()
                .presentationDetents([.medium])
        }
        // Only restores while `selectedTab` is untouched, so it never clobbers a deep link
        // that selected a tab before this view appeared.
        .onAppear {
            if appNavigationModel.selectedTab == .learn, let selectedView, let tab = AppTab(
                rawValue: selectedView,
                learnSectionIDs: Set(lessonsViewModel.librarySectionIDs)
            ) {
                appNavigationModel.selectedTab = tab
            }
            fitSelection()
        }
        .onChange(of: appNavigationModel.selectedTab) { _, newValue in
            // The main tab standing in for a hidden sidebar row isn't saved over that row.
            if let hiddenSelection, newValue == hiddenSelection.parent { return }
            hiddenSelection = nil
            selectedView = newValue.rawValue
        }
        .onChange(of: horizontalSizeClass) {
            fitSelection()
        }
        // A refresh can drop the topic that is showing.
        .onChange(of: lessonsViewModel.librarySectionIDs) { _, ids in
            appNavigationModel.selectedTab = appNavigationModel.selectedTab.validatedLearnSelection(sectionIDs: ids)
        }
        .onChange(of: categories.map(\.id)) {
            fitSelection()
        }
        // Lives here so the ad covers whichever tab triggered it (see `CrossPromoSignal`). Fetched
        // directly rather than via PrivateAds's `.showAd(when:)` so a failed fetch can't get the
        // trigger stuck.
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

    /// Moves the selection to something the current layout can show (see `AppTab.fitted`),
    /// or back to `hiddenSelection` once it can be shown again.
    private func fitSelection() {
        let isCompact = !AppTab.sidebarRowsAvailable(horizontalSizeClass: horizontalSizeClass)
        let categoryIDs = Set(categories.map(\.id))
        let selectedTab = appNavigationModel.selectedTab

        if let hiddenSelection, selectedTab == hiddenSelection.parent,
           hiddenSelection.fitted(isCompact: isCompact, categoryIDs: categoryIDs) == hiddenSelection {
            appNavigationModel.selectedTab = hiddenSelection
            return
        }
        let fitted = selectedTab.fitted(isCompact: isCompact, categoryIDs: categoryIDs)
        if fitted != selectedTab {
            hiddenSelection = selectedTab
            appNavigationModel.selectedTab = fitted
        }
    }

    func getCurrentAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
}

private extension View {
    /// Prefers the sidebar for the adaptable tab view where the system supports it (iOS 27+).
    @ViewBuilder
    func drinkoTabBarPlacement() -> some View {
        if #available(iOS 27, *) {
            defaultTabBarPlacement(.sidebar)
        } else {
            self
        }
    }
}

#if DEBUG
#Preview {
    HomeView()
        .drinkoPreviewEnvironment()
}
#endif
