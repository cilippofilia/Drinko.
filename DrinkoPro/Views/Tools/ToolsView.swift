//
//  ToolsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import SwiftUI

/// The Tools tab: calculators and other bar utilities.
struct ToolsView: View {
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            LibraryView(
                recentsTitle: "",
                recents: [Selection](),
                sections: ToolsLibrary.sections,
                selection: selection,
                isSearching: false,
                collapsedSections: .constant(CollapsedSections()),
                layout: .grid,
                showsSectionHeaders: false,
                onSelect: select,
                cardModel: ToolsLibrary.cardModel(for:),
                contextMenu: { _ in EmptyView() }
            )
            .navigationTitle("Tools")
            #if os(iOS) || os(macOS)
            .crossPromoBanner()
            #endif
        } detail: {
            NavigationStack {
                if let selection {
                    ToolsDetailView(selection: selection)
                } else {
                    ContentUnavailableView(
                        "Select a Tool",
                        systemImage: "wrench.and.screwdriver",
                        description: Text("Choose a calculator to get started.")
                    )
                }
            }
            // Recreate the detail so calculator inputs reset on a new selection.
            .id(selection)
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
