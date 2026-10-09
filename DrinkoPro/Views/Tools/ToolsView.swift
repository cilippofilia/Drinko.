//
//  ToolsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import SwiftUI

/// The Tools tab: calculators and other bar utilities.
struct ToolsView: View {
    #if os(iOS)
    @State private var path: [Selection] = []
    #else
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif

    var body: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            library
                .navigationDestination(for: Selection.self) { item in
                    ToolsDetailView(selection: item)
                }
        }
        #else
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            library
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
        #endif
    }

    private var library: some View {
        LibraryView(
            recentsTitle: "",
            recents: [Selection](),
            sections: ToolsLibrary.sections,
            selection: currentSelection,
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
    }

    private var currentSelection: Selection? {
        #if os(iOS)
        path.first
        #else
        selection
        #endif
    }

    /// Opens `item`: pushes it on iOS, shows it in the detail column on macOS.
    private func select(_ item: Selection) {
        #if os(iOS)
        path = [item]
        #else
        selection = item
        preferredCompactColumn = .detail
        #endif
    }
}

#if DEBUG
#Preview {
    ToolsView()
        .drinkoPreviewEnvironment()
}
#endif
