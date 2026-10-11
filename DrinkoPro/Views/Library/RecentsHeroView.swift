//
//  RecentsHeroView.swift
//  DrinkoPro
//

import SwiftUI

/// The "Last Read" / "Last Viewed" band at the top of a library: a small label, the centred
/// item's name in huge type, and a row of three items (the centred one large, its neighbours
/// smaller) in front of the name, over a backdrop that takes its color or photo from the items.
/// The band keeps one height whatever the name's length.
///
/// The band runs edge to edge (the caller must not pad it). Its backdrop extends upwards
/// behind the navigation bar, large title and search field, and past the top when the list is
/// pulled down, so the whole header area is tinted rather than just a card. Because that area
/// sits behind system chrome, the label and hero text pick white or near-black from the
/// backdrop's luminance.
///
/// The scroll view does the carousel work: each swipe snaps to an item, and with three or more
/// items the row loops endlessly in both directions. Tapping the centred item opens it; tapping a
/// neighbour brings it to the centre first.
struct RecentsHeroView<Item: Identifiable & Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let items: [Item]
    let cardModel: @MainActor (Item) -> LibraryCardModel
    let onOpen: @MainActor (Item) -> Void

    /// The centred slot, kept in sync with the scroll view's position. When the carousel loops
    /// it lays out many copies of the items, so a slot is a position in that row, not an item
    /// (see `RecentsHeroLayout.itemIndex(forSlot:count:)`).
    @State private var currentSlot: Int?
    /// The carousel's width, which sizes the items and the margins that centre them.
    @State private var containerWidth = 0.0
    /// The scroll view's horizontal offset, measured from the first slot being centred.
    @State private var scrollOffset = 0.0

    /// The hero text's size. A scaled metric keeps it following Dynamic Type while being far
    /// larger than any text style.
    @ScaledMetric(relativeTo: .largeTitle) private var heroFontSize = 56.0

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

    private var itemWidth: Double {
        RecentsHeroLayout.itemWidth(forContainerWidth: containerWidth)
    }

    /// How far, in slots, the scroll view is from the first slot. Zero until the width is known.
    private var position: RecentsHeroLayout.Position? {
        let fractionalSlot = itemWidth > 0 ? scrollOffset / itemWidth : 0
        return RecentsHeroLayout.position(forFractionalIndex: fractionalSlot, count: slotCount)
    }

    private func backdrop(atSlot slot: Int) -> RecentsHeroLayout.Backdrop {
        let index = RecentsHeroLayout.itemIndex(forSlot: slot, count: items.count)
        guard items.indices.contains(index) else { return .neutral }
        return RecentsHeroLayout.backdrop(for: cardModel(items[index]).image)
    }

    /// The fraction between the two backdrops. With Reduce Motion it snaps to the nearer one
    /// (and the change is animated), so the band cross-fades instead of drifting with the finger.
    private var backdropFraction: Double {
        let fraction = position?.fraction ?? 0
        return reduceMotion ? fraction.rounded() : fraction
    }

    private var lowerBackdrop: RecentsHeroLayout.Backdrop {
        backdrop(atSlot: position?.lowerIndex ?? homeSlot)
    }

    private var upperBackdrop: RecentsHeroLayout.Backdrop {
        backdrop(atSlot: position?.upperIndex ?? homeSlot)
    }

    /// Whether the text over the band should be light or dark, from the blended backdrop.
    private var textStyle: RecentsHeroLayout.TextStyle {
        RecentsHeroLayout.textStyle(forLuminance: luminance)
    }

    private var luminance: Double {
        let lower = backdropLuminance(lowerBackdrop)
        let upper = backdropLuminance(upperBackdrop)
        return lower + (upper - lower) * backdropFraction
    }

    @Environment(\.self) private var environment

    /// Photos are always darkened by their scrim, so they count as dark.
    private func backdropLuminance(_ backdrop: RecentsHeroLayout.Backdrop) -> Double {
        if backdrop.photoURL != nil { return 0.1 }
        let resolved = backdrop.color(in: colorScheme).resolve(in: environment)
        return RecentsHeroLayout.luminance(
            red: Double(resolved.red),
            green: Double(resolved.green),
            blue: Double(resolved.blue)
        )
    }

    private var textColor: Color {
        textStyle == .light ? .white : .black.opacity(0.85)
    }

    var body: some View {
        VStack(spacing: 0) {
            RecentsHeroHeader(title: title, textColor: textColor)

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
                // The items start about a line into the name, so they overlap its lower part
                // and any further lines.
                .padding(.top, heroFontSize)
                // The name is drawn twice, outside the layout so a long name never changes the
                // band's height: once behind the items, and once in front of them with the
                // centre slot cut out. The centred item covers the name; its neighbours sit
                // behind it.
                .background(alignment: .topLeading) {
                    heroName
                }
                .overlay(alignment: .topLeading) {
                    heroName
                        .mask {
                            RecentsHeroCentreCutout(width: itemWidth)
                        }
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                }
        }
        .frame(maxWidth: .infinity)
        .background {
            // Padding by a negative amount makes the backdrop taller than the band without
            // affecting layout, so it reaches behind the navigation bar and over a pull-down.
            RecentsHeroBackground(lower: lowerBackdrop, upper: upperBackdrop, fraction: backdropFraction)
                .padding(.top, -Self.backdropExtension)
                .animation(reduceMotion ? .easeInOut : nil, value: backdropFraction)
        }
        .onAppear {
            if currentSlot == nil {
                currentSlot = homeSlot
            }
        }
        .onChange(of: items) {
            currentSlot = homeSlot
        }
    }

    /// How far above the band the backdrop reaches: more than the navigation bar, large title
    /// and search field together, with room for a long pull-down.
    private static var backdropExtension: CGFloat { 600 }

    private var carousel: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(0..<slotCount, id: \.self) { slot in
                    let item = items[RecentsHeroLayout.itemIndex(forSlot: slot, count: items.count)]
                    RecentsHeroItem(model: cardModel(item)) {
                        select(slot: slot, item: item)
                    }
                    .frame(width: itemWidth)
                    .visualEffect { [itemWidth, reduceMotion] content, proxy in
                        // Measure against the scroll view's visible bounds in the same space,
                        // since that space's origin is offset by the content margins.
                        let space = NamedCoordinateSpace.scrollView(axis: .horizontal)
                        let visibleMidX = proxy.bounds(of: space)?.midX ?? 0
                        let distance = abs(proxy.frame(in: space).midX - visibleMidX)
                        let progress = itemWidth > 0 ? min(distance / itemWidth, 1) : 0
                        return content
                            .scaleEffect(reduceMotion ? 1 : 1 - 0.3 * progress)
                            .opacity(1 - 0.25 * progress)
                    }
                }
            }
            .scrollTargetLayout()
        }
        // Margins half a width less an item put the first and last slots in the centre.
        .contentMargins(.horizontal, max((containerWidth - itemWidth) / 2, 0), for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentSlot)
        // Once a swipe settles near either end of the copies, jump back to the same item in
        // the middle copy. The copies look identical, so without animation it can't be seen.
        .onScrollPhaseChange { _, newPhase in
            guard newPhase == .idle, let currentSlot else { return }
            let recentered = RecentsHeroLayout.recenteredSlot(currentSlot, count: items.count)
            guard recentered != currentSlot else { return }
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.currentSlot = recentered
            }
        }
        .scrollIndicators(.hidden)
        // Items cast shadows that the scroll view would otherwise clip.
        .scrollClipDisabled()
        .onScrollGeometryChange(for: Double.self) { geometry in
            geometry.contentOffset.x + geometry.contentInsets.leading
        } action: { _, newValue in
            scrollOffset = newValue
        }
        .onGeometryChange(for: Double.self) { proxy in
            proxy.size.width
        } action: { newValue in
            containerWidth = newValue
        }
        .frame(height: itemWidth)
        .padding(.vertical)
    }

    /// The centred item's name. Shared by the copy behind the items and the one in front.
    private var heroName: RecentsHeroName<Int> {
        RecentsHeroName(
            text: currentItem.map { cardModel($0).title } ?? "",
            // The item, not the slot, so re-centring on a copy doesn't animate.
            heroID: currentIndex,
            fontSize: heroFontSize,
            textColor: textColor
        )
    }

    private var accessibilityLabelText: Text {
        guard let currentItem else { return Text(title) }
        return Text("\(title), \(currentIndex + 1) of \(items.count), \(cardModel(currentItem).title)")
    }

    /// Opens the tapped item if it's the centred one; otherwise centres it, so a tap on a
    /// smaller neighbour never opens something other than what the hero text names.
    private func select(slot: Int, item: Item) {
        if slot == currentSlot {
            onOpen(item)
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
