//
//  RecentsHeroView.swift
//  DrinkoPro
//

import SwiftUI

/// The "Last Read" / "Last Viewed" band at the top of a library: a small label, the centred
/// item's name in huge type, and a row of three items (the centred one large, its neighbours
/// smaller) in front of the name, over a backdrop that takes its color or photo from the items.
/// The band keeps one height whatever the name's length. With the `.caption` title style, the
/// name is a plain caption under the row instead, for artwork that would hide the huge type.
///
/// The band runs edge to edge (the caller must not pad it). Its backdrop extends upwards
/// behind the navigation bar, large title and search field, and past the top when the list is
/// pulled down, so the whole header area is tinted rather than just a card. Because that area
/// sits behind system chrome, the label and hero text pick white or near-black from the
/// backdrop's luminance.
///
/// The name, backdrop and text color follow the item the carousel settles on, not every item
/// that passes the centre, so a fast swipe only moves and scales the items.
///
/// The scroll view does the carousel work: each swipe snaps to an item, and with three or more
/// items the row loops endlessly in both directions. Tapping the centred item opens it; tapping a
/// neighbour brings it to the centre first.
struct RecentsHeroView<Item: Identifiable & Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let titleStyle: RecentsHeroTitleStyle
    let items: [Item]
    let cardModel: @MainActor (Item) -> LibraryCardModel
    let onOpen: @MainActor (Item) -> Void

    /// The centred slot, kept in sync with the scroll view's position. When the carousel loops
    /// it lays out many copies of the items, so a slot is a position in that row, not an item
    /// (see `RecentsHeroLayout.itemIndex(forSlot:count:)`).
    @State private var currentSlot: Int?
    /// The carousel's width, which sizes the items and the margins that centre them.
    @State private var containerWidth = 0.0
    /// The slot the carousel last came to rest on, or will once the current swipe ends, which
    /// the name, backdrop and text color follow. It ignores the items a swipe passes over.
    @State private var settledSlot: Int?
    /// Whether the carousel is at rest, so a programmatic jump can settle straight away.
    @State private var isScrollIdle = true
    /// Each item's card model and backdrop, worked out when the items change rather than on
    /// every frame. Built in `refreshEntries()`, not `init`: the parent re-runs `init` on every
    /// update and `State` would throw the result away.
    @State private var entries: [RecentsHeroEntry] = []

    /// The hero text's size. A scaled metric keeps it following Dynamic Type while being far
    /// larger than any text style.
    @ScaledMetric(relativeTo: .largeTitle) private var heroFontSize = 56.0

    init(
        title: String,
        titleStyle: RecentsHeroTitleStyle = .hero,
        items: [Item],
        cardModel: @escaping @MainActor (Item) -> LibraryCardModel,
        onOpen: @escaping @MainActor (Item) -> Void
    ) {
        self.title = title
        self.titleStyle = titleStyle
        self.items = items
        self.cardModel = cardModel
        self.onOpen = onOpen
    }

    private var slotCount: Int {
        RecentsHeroLayout.slotCount(count: items.count)
    }

    /// Where the carousel starts: the first item, in the middle copy when it loops.
    private var homeSlot: Int {
        RecentsHeroLayout.homeSlot(forIndex: 0, count: items.count)
    }

    /// The centred item's position, falling back to the first item before the scroll view reports one.
    private var currentIndex: Int {
        RecentsHeroLayout.itemIndex(forSlot: currentSlot ?? homeSlot, count: items.count)
    }

    private var currentItem: Item? {
        items.indices.contains(currentIndex) ? items[currentIndex] : nil
    }

    /// The centred item's name, empty when there is none.
    private var currentTitle: String {
        entries.indices.contains(currentIndex) ? entries[currentIndex].model.title : ""
    }

    /// The settled item's position, which the name and backdrop show.
    private var settledIndex: Int {
        RecentsHeroLayout.itemIndex(forSlot: settledSlot ?? currentSlot ?? homeSlot, count: items.count)
    }

    /// The settled item's name, empty when there is none.
    private var settledTitle: String {
        entries.indices.contains(settledIndex) ? entries[settledIndex].model.title : ""
    }

    /// The settled item's backdrop, or the neutral tone when there is none.
    private var settledBackdrop: RecentsHeroLayout.Backdrop {
        entries.indices.contains(settledIndex) ? entries[settledIndex].backdrop : .neutral
    }

    private var itemWidth: Double {
        RecentsHeroLayout.itemWidth(forContainerWidth: containerWidth)
    }

    private var textColor: Color {
        switch RecentsHeroLayout.textStyle(forLuminance: settledBackdrop.luminance(in: colorScheme)) {
        case .light:
            .white
        case .dark:
            .black.opacity(0.85)
        }
    }

    /// Rebuilds the per-item data after the items change.
    private func refreshEntries() {
        entries = items.map { RecentsHeroEntry(model: cardModel($0)) }
    }

    var body: some View {
        VStack(spacing: 0) {
            RecentsHeroHeader(title: title, textColor: textColor)

            switch titleStyle {
            case .hero:
                accessibleCarousel
                    // The items start about a line into the name, so they overlap its lower part
                    // and any further lines.
                    .padding(.top, heroFontSize)
                    // The name is drawn twice, outside the layout so a long name never changes the
                    // band's height: once behind the items, and once in front of them with the
                    // centre slot cut out. The centred item covers the name; its neighbours sit
                    // behind it.
                    .background(alignment: .topLeading) {
                        RecentsHeroName(
                            text: settledTitle,
                            heroID: settledIndex,
                            fontSize: heroFontSize,
                            textColor: textColor
                        )
                    }
                    .overlay(alignment: .topLeading) {
                        RecentsHeroName(
                            text: settledTitle,
                            // The item, not the slot, so re-centring on a copy doesn't animate.
                            heroID: settledIndex,
                            fontSize: heroFontSize,
                            textColor: textColor
                        )
                            .mask {
                                RecentsHeroCentreCutout(width: itemWidth)
                            }
                            .accessibilityHidden(true)
                            .allowsHitTesting(false)
                    }
            case .caption:
                accessibleCarousel

                RecentsHeroCaption(text: settledTitle, heroID: settledIndex, textColor: textColor)
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            RecentsHeroSettledBackground(backdrop: settledBackdrop, fadeAboveBottom: titleStyle.fadeAboveBottom)
                // Decoration, so it runs behind a vertical toolbar (iPhone Duo) as it does
                // behind the navigation bar.
                .ignoresSafeArea(edges: .horizontal)
        }
        .onAppear {
            if currentSlot == nil {
                currentSlot = homeSlot
                settledSlot = homeSlot
            }
            refreshEntries()
        }
        .onChange(of: items) {
            currentSlot = homeSlot
            settledSlot = homeSlot
            refreshEntries()
        }
        // Favoriting or re-photographing an item changes its card model without changing
        // `items`, so watch the models themselves and keep the carousel where it is.
        .onChange(of: items.map { cardModel($0) }) {
            refreshEntries()
        }
        // A jump made while the carousel is at rest (one without a scroll animation) never
        // reports a new phase, so settle on it here.
        .onChange(of: currentSlot) {
            if isScrollIdle {
                settledSlot = currentSlot
            }
        }
    }

    /// The carousel as one adjustable element: swipe up or down to move, double tap to open.
    private var accessibleCarousel: some View {
        carousel
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabelText)
            .accessibilityHint("Swipe up or down to browse. Double tap to open.")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    scroll(to: RecentsHeroLayout.nextSlot(currentSlot ?? homeSlot, count: items.count))
                case .decrement:
                    scroll(to: RecentsHeroLayout.previousSlot(currentSlot ?? homeSlot, count: items.count))
                @unknown default:
                    break
                }
            }
            .accessibilityAction {
                if let currentItem {
                    onOpen(currentItem)
                }
            }
    }

    private var carousel: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                // Laid out from `entries`, which catches up with `items` one update later, so
                // the slots and the models they show always agree.
                ForEach(0..<RecentsHeroLayout.slotCount(count: entries.count), id: \.self) { slot in
                    let index = RecentsHeroLayout.itemIndex(forSlot: slot, count: entries.count)
                    RecentsHeroItem(model: entries[index].model) {
                        select(slot: slot, index: index)
                    }
                    .frame(width: itemWidth)
                    .visualEffect { [itemWidth, containerWidth, reduceMotion] content, proxy in
                        // The scroll view's visible bounds come back in the item's own
                        // coordinates, so compare their centre with the item's.
                        let space = NamedCoordinateSpace.scrollView(axis: .horizontal)
                        let visibleMidX = proxy.bounds(of: space)?.midX ?? proxy.size.width / 2
                        let distance = abs(visibleMidX - proxy.size.width / 2)
                        let progress = itemWidth > 0 ? min(distance / itemWidth, 1) : 0
                        // Items rise as they move out from the centre, along the same curve as
                        // the backdrop's fade, so the row travels in an arc.
                        let lift = RecentsHeroLayout.fadeCurveLift(
                            atDistance: distance,
                            fromCentreOfWidth: containerWidth
                        )
                        return content
                            .scaleEffect(reduceMotion ? 1 : 1 - 0.36 * progress)
                            .offset(y: reduceMotion ? 0 : -lift)
                    }
                }
            }
            .scrollTargetLayout()
        }
        // Margins half a width less an item put the first and last slots in the centre.
        .contentMargins(.horizontal, max((containerWidth - itemWidth) / 2, 0), for: .scrollContent)
        // Settle on the item a swipe will end on as soon as the finger lifts, rather than
        // waiting for the deceleration to finish.
        .scrollTargetBehavior(RecentsHeroSnapBehavior(itemWidth: itemWidth) { slot in
            if (0..<slotCount).contains(slot), slot != settledSlot {
                settledSlot = slot
            }
        })
        .scrollPosition(id: $currentSlot)
        // Once a swipe comes to rest, settle on the centred item. Near either end of the
        // copies, also jump back to the same item in the middle copy. The copies look
        // identical, so without animation it can't be seen.
        .onScrollPhaseChange { _, newPhase in
            isScrollIdle = newPhase == .idle
            guard isScrollIdle, let currentSlot else { return }
            let recentered = RecentsHeroLayout.recenteredSlot(currentSlot, count: items.count)
            if recentered != currentSlot {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    self.currentSlot = recentered
                }
            }
            settledSlot = recentered
        }
        .scrollIndicators(.hidden)
        // Items cast shadows that the scroll view would otherwise clip.
        .scrollClipDisabled()
        .onGeometryChange(for: Double.self) { proxy in
            proxy.size.width
        } action: { newValue in
            containerWidth = newValue
        }
        .frame(height: itemWidth)
        .padding(.vertical)
    }

    private var accessibilityLabelText: Text {
        guard currentItem != nil else { return Text(title) }
        let label = Text("\(title), \(currentIndex + 1) of \(items.count), \(currentTitle)")
        guard entries.indices.contains(currentIndex), entries[currentIndex].model.isFavorite else { return label }
        return label + Text(verbatim: ", ") + Text("Favorite")
    }

    /// Opens the tapped item if it's the centred one; otherwise centres it, so a tap on a
    /// smaller neighbour never opens something other than what the hero text names.
    private func select(slot: Int, index: Int) {
        guard items.indices.contains(index) else { return }
        if slot == currentSlot {
            onOpen(items[index])
        } else {
            scroll(to: slot)
        }
    }

    private func scroll(to slot: Int) {
        guard (0..<slotCount).contains(slot) else { return }
        withAnimation(reduceMotion ? nil : .snappy) {
            currentSlot = slot
        }
    }
}

#if DEBUG
/// A minimal `Identifiable` item for previews, carrying its artwork.
private struct PreviewItem: Identifiable, Hashable {
    let id: String
    let image: LibraryImage
}

private func stickerURL(_ name: String) -> URL? {
    URL(string: "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main/drinko-\(name).png")
}

/// Shows the band through `LibraryView`, inside a navigation stack, so the previews also show
/// the navigation bar's title and search field adapting to the backdrop.
private struct PreviewHero: View {
    let items: [PreviewItem]
    @State private var collapsed = CollapsedSections()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            LibraryView(
                title: "Cocktails",
                recentsTitle: "Last Viewed",
                recents: items,
                sections: [LibrarySection(id: "a", title: "A", items: items)],
                selection: nil,
                isSearching: false,
                collapsedSections: $collapsed,
                layout: .grid,
                onSelect: { _ in },
                cardModel: { LibraryCardModel(title: $0.id, image: $0.image, imageContentMode: .fill) },
                contextMenu: { _ in EmptyView() }
            )
            .navigationTitle("Cocktails")
            .searchable(text: $searchText)
        }
    }
}

#Preview("Stickers") {
    PreviewHero(items: [
        PreviewItem(
            id: "Philadelphia Fish House Punch",
            image: .sticker(stickerURL("philadelphia-fish-house-punch"), tint: "Dr. Orange")
        ),
        PreviewItem(id: "Aperol Spritz", image: .sticker(stickerURL("aperol-spritz"), tint: "Dr. Gold")),
        PreviewItem(id: "Americano", image: .sticker(stickerURL("americano-cocktail"), tint: "Dr. Lavender")),
        PreviewItem(id: "Dry Martini", image: .sticker(stickerURL("dry-martini"), tint: "Dr. Magenta")),
        PreviewItem(id: "Manhattan", image: .sticker(stickerURL("manhattan"), tint: "Dr. Red"))
    ])
}

#Preview("Photos") {
    let base = "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main"
    PreviewHero(items: [
        PreviewItem(id: "Gin", image: .remote(URL(string: "\(base)/gin.jpg"))),
        PreviewItem(id: "Cocktail Codex", image: .remote(URL(string: "\(base)/cocktail-codex.jpg"))),
        PreviewItem(id: "Liqueurs", image: .remote(URL(string: "\(base)/liqueurs-basics.jpg"))),
        PreviewItem(id: "Symbols and a very long name", image: .symbol("wineglass"))
    ])
}
#endif
