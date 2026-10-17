//
//  LibraryView.swift
//  DrinkoPro
//

import SwiftUI

/// The library column for Learn and Cocktails: a recents band followed by collapsible sections.
/// The band runs edge to edge, so only the sections are padded.
struct LibraryView<Item: Identifiable & Hashable, MenuContent: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Shown by the recents band's label while the band is at the top (see `showsBarTitle`).
    let title: String
    let recentsTitle: String
    var recentsTitleStyle: RecentsHeroTitleStyle = .hero
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

    /// Shared by the layout switch and the section collapse, so Reduce Motion is honored
    /// consistently.
    private var collapseAndLayoutAnimation: Animation? {
        reduceMotion ? nil : .snappy
    }

    private var showsRecents: Bool {
        !isSearching && !recents.isEmpty
    }

    /// A flag rather than the raw offset, so scrolling only updates the view when it flips.
    @State private var hasScrolledUnderBar = false

    /// About the band's label, so the title takes over just as the label slides away.
    @ScaledMetric(relativeTo: .footnote) private var barTitleScrollThreshold = 24.0

    /// Hidden while the recents band is at the top: its pale backdrop sits behind the bar, where
    /// the system title (white in dark mode) would be hard to read.
    private var showsBarTitle: Bool {
        !showsRecents || hasScrolledUnderBar
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if showsRecents {
                    RecentsHeroView(
                        title: "\(title) · \(recentsTitle)",
                        titleStyle: recentsTitleStyle,
                        items: recents,
                        cardModel: cardModel,
                        onOpen: onSelect
                    )
                }

                ForEach(sections) { section in
                    let isCollapsed = showsSectionHeaders
                        && collapsedSections.isCollapsed(section.id, whileSearching: isSearching)

                    LibrarySectionView(
                        section: section,
                        layout: layout,
                        showsHeader: showsSectionHeaders,
                        isCollapsed: isCollapsed,
                        isCollapsible: showsSectionHeaders && !isSearching,
                        selection: selection,
                        onToggleCollapsed: {
                            withAnimation(collapseAndLayoutAnimation) {
                                collapsedSections.toggle(section.id)
                            }
                        },
                        onSelect: { onSelect($0) },
                        cardModel: { cardModel($0) },
                        contextMenu: { contextMenu($0) }
                    )
                    .padding(.horizontal)
                    // Collapsed headers stack closely; their 44-point tap targets already space them.
                    .padding(.bottom, isCollapsed ? 0 : nil)
                }
            }
            .animation(collapseAndLayoutAnimation, value: layout)
        }
        .onScrollGeometryChange(for: Bool.self) { [barTitleScrollThreshold] geometry in
            // The bar's bottom edge in content coordinates: 0 at rest, negative when pulled down.
            RecentsHeroLayout.hasScrolledUnderBar(
                barBottom: geometry.contentOffset.y + geometry.contentInsets.top,
                threshold: barTitleScrollThreshold
            )
        } action: { _, newValue in
            hasScrolledUnderBar = newValue
        }
        #if os(iOS)
        // Library screens always use the compact inline title, so the recents band's huge
        // item name is the screen's only large heading.
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline)
                    .opacity(showsBarTitle ? 1 : 0)
                    .accessibilityHidden(!showsBarTitle)
                    .animation(reduceMotion ? nil : .easeInOut, value: showsBarTitle)
            }
        }
        #endif
    }
}

#if DEBUG
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
            title: "Cocktails",
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
