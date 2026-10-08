//
//  LibraryView.swift
//  DrinkoPro
//

import SwiftUI

/// The shared sidebar body for Learn and Cocktails: a recents deck followed by collapsible sections.
///
/// Screens own their data, selection and persisted state; this view only renders it.
struct LibraryView<Item: Identifiable & Hashable, MenuContent: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

    /// A single animation shared by the layout switch and the section collapse, so Reduce
    /// Motion is honored consistently and the layout switch isn't animated twice (this view
    /// and `LibraryLayoutToggle` would otherwise each animate the same change).
    private var collapseAndLayoutAnimation: Animation? {
        reduceMotion ? nil : .snappy
    }

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
                            withAnimation(collapseAndLayoutAnimation) {
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
            .animation(collapseAndLayoutAnimation, value: layout)
        }
    }
}

#if DEBUG
/// A minimal `Identifiable` item for previews.
private struct PreviewItem: Identifiable, Hashable {
    let id: String
}

#Preview {
    @Previewable @State var collapsed = CollapsedSections()
    let recents = ["Negroni", "Daiquiri", "Martini"].map(PreviewItem.init(id:))
    let sectionA = ["Americano", "Aviation"].map(PreviewItem.init(id:))
    let sectionB = ["Bramble", "Boulevardier", "Bee's Knees"].map(PreviewItem.init(id:))
    NavigationStack {
        LibraryView(
            recentsTitle: "Last Viewed",
            recents: recents,
            sections: [
                LibrarySection(id: "a", title: "A", items: sectionA),
                LibrarySection(id: "b", title: "B", items: sectionB)
            ],
            selection: sectionA[1],
            isSearching: false,
            collapsedSections: $collapsed,
            layout: .grid,
            onSelect: { _ in },
            cardModel: { LibraryCardModel(title: $0.id, image: .symbol("wineglass"), imageContentMode: .fit) },
            contextMenu: { _ in EmptyView() }
        )
        .navigationTitle("Cocktails")
    }
}
#endif
