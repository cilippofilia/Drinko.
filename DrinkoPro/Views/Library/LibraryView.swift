//
//  LibraryView.swift
//  DrinkoPro
//

import SwiftUI

/// The shared sidebar body for Learn and Cocktails: a recents deck followed by collapsible sections.
///
/// Screens own their data, selection and persisted state; this view only renders it.
struct LibraryView<Item: Hashable, MenuContent: View>: View {
    let recentsTitle: String
    let recents: [Item]
    let sections: [LibrarySection<Item>]
    let selection: Item?
    let isSearching: Bool
    @Binding var collapsedSections: CollapsedSections
    let layout: LibraryLayout
    /// `false` hides the collapsible section headers and always shows every section's items.
    var showsSectionHeaders = true
    let onSelect: @MainActor (Item) -> Void
    let cardModel: @MainActor (Item) -> LibraryCardModel
    @ViewBuilder let contextMenu: @MainActor (Item) -> MenuContent

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if !isSearching && !recents.isEmpty {
                    RecentsDeckView(
                        title: recentsTitle,
                        items: recents,
                        cardModel: cardModel,
                        onOpen: onSelect
                    )
                }

                ForEach(sections) { section in
                    LibrarySectionView(
                        section: section,
                        layout: layout,
                        showsHeader: showsSectionHeaders,
                        isCollapsed: showsSectionHeaders
                            && collapsedSections.isCollapsed(section.id, whileSearching: isSearching),
                        isCollapsible: showsSectionHeaders && !isSearching,
                        selection: selection,
                        onToggleCollapsed: {
                            withAnimation(.snappy) {
                                collapsedSections.toggle(section.id)
                            }
                        },
                        onSelect: onSelect,
                        cardModel: cardModel,
                        contextMenu: contextMenu
                    )
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .animation(.snappy, value: layout)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var collapsed = CollapsedSections()
    NavigationStack {
        LibraryView(
            recentsTitle: "Last Viewed",
            recents: ["Negroni", "Daiquiri", "Martini"],
            sections: [
                LibrarySection(id: "a", title: "A", items: ["Americano", "Aviation"]),
                LibrarySection(id: "b", title: "B", items: ["Bramble", "Boulevardier", "Bee's Knees"])
            ],
            selection: "Aviation",
            isSearching: false,
            collapsedSections: $collapsed,
            layout: .grid,
            onSelect: { _ in },
            cardModel: { LibraryCardModel(title: $0, image: .symbol("wineglass"), imageContentMode: .fit) },
            contextMenu: { _ in EmptyView() }
        )
        .navigationTitle("Cocktails")
    }
}
#endif
