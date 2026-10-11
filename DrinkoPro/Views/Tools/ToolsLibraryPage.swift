//
//  ToolsLibraryPage.swift
//  DrinkoPro
//

import SwiftUI

/// The Tools library column: the calculators as a grid of cards.
struct ToolsLibraryPage: View {
    /// The tool currently shown, highlighted in the library.
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
            onSelect: onSelect,
            cardModel: ToolsLibrary.cardModel(for:),
            contextMenu: { _ in EmptyView() }
        )
        .navigationTitle("Tools")
        #if os(iOS) || os(macOS)
        .crossPromoBanner()
        #endif
    }
}
