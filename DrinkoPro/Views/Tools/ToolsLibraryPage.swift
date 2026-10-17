//
//  ToolsLibraryPage.swift
//  DrinkoPro
//

import SwiftUI

struct ToolsLibraryPage: View {
    let selection: ToolsView.Selection?
    let onSelect: @MainActor (ToolsView.Selection) -> Void

    var body: some View {
        LibraryView(
            title: String(localized: "Tools"),
            recentsTitle: "",
            recents: [ToolsView.Selection](),
            sections: ToolsLibrary.sections,
            selection: selection,
            isSearching: false,
            collapsedSections: .constant(CollapsedSections()),
            layout: .grid,
            showsSectionHeaders: false,
            onSelect: { onSelect($0) },
            cardModel: { ToolsLibrary.cardModel(for: $0) },
            contextMenu: { _ in EmptyView() }
        )
        .navigationTitle("Tools")
        #if os(iOS) || os(macOS)
        .crossPromoBanner()
        #endif
    }
}
