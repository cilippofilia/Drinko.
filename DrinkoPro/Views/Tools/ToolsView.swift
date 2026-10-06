//
//  ToolsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import SwiftUI

/// The Tools tab: calculators and other bar utilities.
struct ToolsView: View {
    static let toolsTag: String? = "Tools"

    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    @AppStorage(LibraryLayout.toolsStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage("toolsCollapsedSections") private var collapsedSections = CollapsedSections()

    private var layoutTogglePlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .automatic
        #endif
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            LibraryView(
                recentsTitle: "",
                recents: [Selection](),
                sections: ToolsLibrary.sections,
                selection: selection,
                isSearching: false,
                collapsedSections: $collapsedSections,
                layout: layout,
                onSelect: select,
                cardModel: ToolsLibrary.cardModel(for:),
                contextMenu: { _ in EmptyView() }
            )
            .navigationTitle("Tools")
            .toolbar {
                ToolbarItem(placement: layoutTogglePlacement) {
                    LibraryLayoutToggle(layout: $layout)
                }
            }
            #if os(iOS) || os(macOS)
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
            #endif
        } detail: {
            if let selection {
                ToolsDetailView(selection: selection)
                    // Recreate the detail so calculator inputs reset on a new selection.
                    .id(selection)
            } else {
                ContentUnavailableView(
                    "Select a Tool",
                    systemImage: "wrench.and.screwdriver",
                    description: Text("Choose a calculator to get started.")
                )
            }
        }
    }

    /// Opens `item` in the detail column, pushing it on compact widths.
    private func select(_ item: Selection) {
        selection = item
        preferredCompactColumn = .detail
    }
}

#if DEBUG
#Preview {
    ToolsView()
        .drinkoPreviewEnvironment()
}
#endif
