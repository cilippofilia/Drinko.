//
//  RecentsHeroLayout.swift
//  DrinkoPro
//

import SwiftUI

/// The pure logic behind the recents hero band: looping and slot stepping, how scroll progress maps onto
/// the two items being blended, which backdrop each item gets, and whether text over a backdrop
/// should be light or dark.
///
/// Keeping this out of the views means the accessibility actions, the backdrop blending and the
/// legibility rule can all be tested without a view hierarchy.
enum RecentsHeroLayout {
    // MARK: - Looping

    /// How many copies of the items the carousel lays out when it loops. It starts in the
    /// middle copy, so there are hundreds of swipes either way before it nears an end, and it
    /// quietly re-centres before it gets there (see `recenteredSlot`). The row is lazy, so
    /// the copies cost nothing until they scroll into view.
    static let loopCopies = 50

    /// Whether the carousel loops. With three items showing at once, looping fewer than three
    /// would put the same item on both sides of the centre.
    static func isLooping(count: Int) -> Bool {
        count >= 3
    }

    /// How many slots the carousel lays out: every copy of every item when it loops,
    /// otherwise just the items.
    static func slotCount(count: Int) -> Int {
        isLooping(count: count) ? count * loopCopies : max(count, 0)
    }

    /// The item shown in `slot`.
    static func itemIndex(forSlot slot: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((slot % count) + count) % count
    }

    /// The slot for the item at `index` in the middle copy, where the carousel starts.
    static func homeSlot(forIndex index: Int, count: Int) -> Int {
        guard isLooping(count: count) else { return index }
        return count * (loopCopies / 2) + itemIndex(forSlot: index, count: count)
    }

    /// Where to jump, without animation, once the carousel comes to rest in `slot`: the same
    /// item in the middle copy when `slot` is within a copy of either end, otherwise `slot`
    /// itself. Every copy looks the same, so the jump is invisible.
    static func recenteredSlot(_ slot: Int, count: Int) -> Int {
        guard isLooping(count: count) else { return slot }
        let isNearEnd = slot < count || slot >= slotCount(count: count) - count
        return isNearEnd ? homeSlot(forIndex: slot, count: count) : slot
    }

    /// The slot after moving to the next item (the one on the right). Stays on the last slot
    /// rather than running off the end, which only a non-looping carousel ever reaches.
    static func nextSlot(_ slot: Int, count: Int) -> Int {
        let slots = slotCount(count: count)
        guard slots > 0 else { return 0 }
        return min(max(slot, 0) + 1, slots - 1)
    }

    /// The slot after moving to the previous item (the one on the left). Stays on the first
    /// slot rather than running off the start.
    static func previousSlot(_ slot: Int, count: Int) -> Int {
        let slots = slotCount(count: count)
        guard slots > 0 else { return 0 }
        return max(min(slot, slots - 1) - 1, 0)
    }

    // MARK: - Sizing

    /// How much of the band's width the centred item takes. A third of the width would leave
    /// the shrunken neighbours with wide gaps; a little more keeps three items reading as one row.
    static let itemWidthFraction = 0.36

    /// The widest an item gets, so the row doesn't balloon on iPad and Mac.
    static let maximumItemWidth = 280.0

    /// How far below the band's bottom edge the fade runs, into the gap before the list, so
    /// the band takes no extra room for it. It ends before the first section header, which
    /// then sits on the plain page background.
    static let fadeBelowBottom = 16.0

    /// The width of one item (and the distance between neighbours' centres) in a band
    /// `containerWidth` wide.
    static func itemWidth(forContainerWidth containerWidth: Double) -> Double {
        min(max(containerWidth, 0) * itemWidthFraction, maximumItemWidth)
    }

    // MARK: - Scroll progress

    /// Which two items the band is between, and how far from the first towards the second.
    struct Position: Equatable {
        let lowerIndex: Int
        let upperIndex: Int
        /// 0 when exactly on `lowerIndex`, approaching 1 as `upperIndex` arrives.
        let fraction: Double
    }

    /// Turns a fractional item position (scroll offset divided by item stride) into the pair of
    /// items to blend. Clamped at both ends so rubber-banding past the first or last item
    /// holds the end item's backdrop instead of reaching for one that doesn't exist.
    /// `nil` when there are no items.
    static func position(forFractionalIndex value: Double, count: Int) -> Position? {
        guard count > 0 else { return nil }
        let clamped = min(max(value.isFinite ? value : 0, 0), Double(count - 1))
        let lower = Int(clamped.rounded(.down))
        let upper = min(lower + 1, count - 1)
        return Position(lowerIndex: lower, upperIndex: upper, fraction: clamped - Double(lower))
    }

    /// Like `position(forFractionalIndex:count:)`, but for a fractional *slot* of a carousel
    /// showing `itemCount` items: both ends are mapped back onto items (a looping carousel's
    /// slots repeat them), and with `snapsFraction` the fraction jumps to the nearer end instead
    /// of gliding, which is what Reduce Motion wants. `nil` when there are no items.
    static func itemPosition(forFractionalSlot value: Double, itemCount: Int, snapsFraction: Bool) -> Position? {
        guard let slots = position(forFractionalIndex: value, count: slotCount(count: itemCount)) else {
            return nil
        }
        return Position(
            lowerIndex: itemIndex(forSlot: slots.lowerIndex, count: itemCount),
            upperIndex: itemIndex(forSlot: slots.upperIndex, count: itemCount),
            fraction: snapsFraction ? slots.fraction.rounded() : slots.fraction
        )
    }

    /// The value `fraction` of the way from `start` to `end`.
    static func interpolated(from start: Double, to end: Double, fraction: Double) -> Double {
        start + (end - start) * fraction
    }

    /// The backdrop luminance at a fractional slot, blended from each item's own luminance
    /// (one entry per item), so the scroll handler can pick the text style for every frame
    /// without resolving colors. `fallback` is returned when there are no items.
    static func blendedLuminance(
        atFractionalSlot value: Double,
        itemLuminances: [Double],
        snapsFraction: Bool,
        fallback: Double
    ) -> Double {
        guard let position = itemPosition(
            forFractionalSlot: value,
            itemCount: itemLuminances.count,
            snapsFraction: snapsFraction
        ) else {
            return fallback
        }
        return interpolated(
            from: itemLuminances[position.lowerIndex],
            to: itemLuminances[position.upperIndex],
            fraction: position.fraction
        )
    }

    // MARK: - Backdrops

    /// What fills the band behind an item.
    enum Backdrop: Hashable {
        /// A solid color from the named color asset.
        case color(String)
        /// A blurred copy of the item's photo.
        case photo(URL)
        /// Nothing worth drawing from: a quiet, system-adaptive tone.
        case neutral
    }

    /// The backdrop for an item's artwork. Stickers (bundled or the user's) and tinted glass take
    /// that tint's color, photos are blurred into a wallpaper, and everything else (untinted
    /// stickers or glass, assets, symbols, photos without a URL) gets the neutral tone.
    static func backdrop(for image: LibraryImage) -> Backdrop {
        switch image {
        case .sticker(_, let tint?), .userSticker(_, _, let tint?), .glass(_, let tint?):
            .color(tint)
        case .remote(let url?):
            .photo(url)
        case .sticker, .userSticker, .glass, .remote, .asset, .symbol, .userPhoto:
            .neutral
        }
    }

    // MARK: - Legibility

    /// Which text color reads well on a backdrop.
    enum TextStyle: Equatable {
        /// White text, for dark backdrops.
        case light
        /// Near-black text, for light backdrops.
        case dark
    }

    /// The luminance above which a backdrop is light enough to need dark text. Sits a little
    /// above the midpoint because white text stays readable on mid-tones a touch longer than
    /// black does, especially in bold, large type.
    static let darkTextThreshold = 0.6

    /// A color's perceived brightness from 0 (black) to 1 (white), from its gamma-encoded
    /// sRGB components, using the Rec. 601 weights.
    static func luminance(red: Double, green: Double, blue: Double) -> Double {
        0.299 * red + 0.587 * green + 0.114 * blue
    }

    /// The text style for a backdrop with the given luminance.
    static func textStyle(forLuminance luminance: Double) -> TextStyle {
        luminance > darkTextThreshold ? .dark : .light
    }

    // MARK: - Navigation bar

    /// Whether the content has scrolled more than `threshold` under the navigation bar.
    ///
    /// `barBottom` is where the bar's bottom edge falls in content coordinates (the scroll
    /// view's vertical offset plus its top inset): 0 at rest, negative when pulled down.
    static func hasScrolledUnderBar(barBottom: Double, threshold: Double) -> Bool {
        barBottom > threshold
    }
}
