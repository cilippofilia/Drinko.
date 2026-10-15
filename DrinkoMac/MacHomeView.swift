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

    // Cabinet categories for the sidebar's Cabinet group (same order as the Cabinet page).
    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) private var categories: [Category]

    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var interstitialAd: Ad?
    @State private var showRemoveAdsPaywall = false

    /// The sidebar selection. Ignores `nil`, so a click on empty space can't deselect the row.
    private var sidebarSelection: Binding<AppTab?> {
        Binding(
            get: { appNavigationModel.selectedTab },
            set: { newValue in
                if let newValue {
                    appNavigationModel.selectedTab = newValue
                }
            }
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: sidebarSelection) {
                Label("Learn", systemImage: "books.vertical.fill")
                    .tag(AppTab.learn)
                Label("Cabinet", systemImage: "cabinet.fill")
                    .tag(AppTab.cabinet)
                Label("Cocktails", systemImage: "wineglass.fill")
                    .tag(AppTab.cocktails)
                Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                    .tag(AppTab.tools)
                Label("Settings", systemImage: "gear")
                    .tag(AppTab.settings)

                Section("Cocktails") {
                    ForEach(AppTab.sidebarCocktailFilters, id: \.self) { filter in
                        Label(filter.sidebarTitle, systemImage: filter.sidebarSymbol)
                            .tag(AppTab.cocktailFilter(filter))
                    }
                }
                Section("Tools") {
                    ForEach(ToolsLibrary.calculatorItems) { item in
                        Label(
                            ToolsLibrary.cardModel(for: item).title,
                            systemImage: ToolsLibrary.sidebarSymbol(for: item)
                        )
                        .tag(AppTab.tool(item))
                    }
                }
                Section("Learn") {
                    ForEach(LessonsViewModel.librarySectionIDs, id: \.self) { id in
                        Label(
                            LessonsViewModel.sectionTitle(for: id) ?? "",
                            systemImage: LessonsViewModel.sidebarSymbol(for: id)
                        )
                        .tag(AppTab.learnSection(id))
                    }
                }
                if !categories.isEmpty {
                    Section("Cabinet") {
                        ForEach(categories) { category in
                            Label(category.name, systemImage: "tray")
                                .tag(AppTab.cabinetCategory(category.id))
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if removeAdsStore.isAdsRemoved == false {
                    Button("Remove Ads", systemImage: "nosign") {
                        showRemoveAdsPaywall = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .navigationSplitViewColumnWidth(
                min: 140,
                ideal: 180,
                max: 220
            )
        } detail: {
            MacHomeDetailView(tab: appNavigationModel.selectedTab)
        }
        // Restore the last-used row from the previous session. Only applies while
        // `selectedTab` is still at its untouched default, so it never clobbers a deep link
        // that already selected a tab before this view first appeared.
        .onAppear {
            if appNavigationModel.selectedTab == .learn, let selectedView, let tab = AppTab(rawValue: selectedView) {
                appNavigationModel.selectedTab = tab
            }
            fitSelection()
        }
        .onChange(of: appNavigationModel.selectedTab) { _, newValue in
            selectedView = newValue.rawValue
        }
        // A selected Cabinet category row disappears when the category is deleted.
        .onChange(of: categories.map(\.id)) {
            fitSelection()
        }
        .sheet(isPresented: $showRemoveAdsPaywall) {
            CrossPromoRemoveAdsInfoView()
                .frame(minWidth: 420, minHeight: 480)
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
        appNavigationModel.selectedTab = appNavigationModel.selectedTab.fitted(isCompact: false, categoryIDs: categoryIDs)
    }
}

#if DEBUG
#Preview {
    MacHomeView()
        .drinkoPreviewEnvironment()
}
#endif
