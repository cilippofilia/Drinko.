//
//  LibraryView.swift
//  DrinkoPro
//

import SwiftUI

/// The shared sidebar body for Learn and Cocktails: a recents hero band followed by collapsible sections.
///
/// The hero runs edge to edge so its backdrop can fill the width; it pads its own text, and the
/// sections carry the horizontal padding the stack used to apply.
///
/// Screens own their data, selection and persisted state; this view only renders it.
struct LibraryView<Item: Identifiable & Hashable, MenuContent: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The screen's title. While the recents band sits at the top, the band's label carries it
    /// and the navigation bar's inline title stays hidden (see `showsBarTitle`).
    let title: String
    let recentsTitle: String
    /// How the recents band names its centred item.
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

    /// A single animation shared by the layout switch and the section collapse, so Reduce
    /// Motion is honored consistently and the layout switch isn't animated twice (this view
    /// and `LibraryLayoutToggle` would otherwise each animate the same change).
    private var collapseAndLayoutAnimation: Animation? {
        reduceMotion ? nil : .snappy
    }

    private var showsRecents: Bool {
        !isSearching && !recents.isEmpty
    }

    /// Whether the content has scrolled past `barTitleScrollThreshold` under the navigation bar.
    /// Tracked as a flag rather than the raw offset, so scrolling only updates the view when it
    /// flips.
    @State private var hasScrolledUnderBar = false

    /// How far the content scrolls under the bar before the inline title appears: about the
    /// band's label, so the title takes over the screen's name just as the label slides away.
    @ScaledMetric(relativeTo: .footnote) private var barTitleScrollThreshold = 24.0

    /// The inline title shows unless the recents band is at the top. There, the band's pale
    /// backdrop sits behind the bar and the system title (white in dark mode) would be hard to
    /// read, so the band's label names the screen instead. Once the content scrolls, the bar's
    /// scroll edge effect darkens behind the title and it fades in.
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
                    .padding(.horizontal)
                    .padding(.bottom)
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
