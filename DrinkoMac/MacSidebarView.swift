//
//  MacSidebarView.swift
//  DrinkoMac
//

import SwiftData
import SwiftUI

/// The Mac window's sidebar. Every page puts it in the first column of its own split view
/// (see `MacHomePageView`).
struct MacSidebarView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    // Cabinet categories for the Cabinet group (same order as the Cabinet page).
    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) private var categories: [Category]

    @State private var showRemoveAdsPaywall = false

    /// The sidebar selection. Ignores `nil`, so a click on empty space can't deselect the row.
    private var selection: Binding<AppTab?> {
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
        List(selection: selection) {
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
                Button {
                    showRemoveAdsPaywall = true
                } label: {
                    Label {
                        Text("Remove Ads")
                    } icon: {
                        Image(systemName: "nosign")
                            .foregroundStyle(.red)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                // Rows scroll under the button, so it needs its own backdrop to stay legible.
                .background(.ultraThinMaterial)
            }
        }
        .navigationSplitViewColumnWidth(
            min: 140,
            ideal: 180,
            max: 220
        )
        .sheet(isPresented: $showRemoveAdsPaywall) {
            CrossPromoRemoveAdsInfoView()
                .frame(minWidth: 420, minHeight: 480)
        }
    }
}

#if DEBUG
#Preview {
    MacSidebarView()
        .drinkoPreviewEnvironment()
}
#endif
