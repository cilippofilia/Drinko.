//
//  ToolsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import SwiftUI

struct ToolsView: View {
    #if os(iOS)
    @State private var path: [Selection] = []
    #else
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif

    private var navigation: LibraryNavigationBindings<Selection> {
        #if os(iOS)
        .init(path: $path)
        #else
        .init(selection: $selection, preferredCompactColumn: $preferredCompactColumn)
        #endif
    }

    var body: some View {
        LibraryNavigationContainer(
            navigation: navigation,
            library: { ToolsLibraryPage(selection: currentSelection, onSelect: select) },
            detail: { ToolsDetailView(selection: $0) },
            placeholder: {
                ContentUnavailableView(
                    "Select a Tool",
                    systemImage: "wrench.and.screwdriver",
                    description: Text("Choose a calculator to get started.")
                )
            }
        )
    }

    private var currentSelection: Selection? {
        #if os(iOS)
        path.first
        #else
        selection
        #endif
    }

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
