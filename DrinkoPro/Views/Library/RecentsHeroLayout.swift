//
//  RecentsHeroLayout.swift
//  DrinkoPro
//

import SwiftUI

/// The recents band's logic, kept out of the views so it can be tested without a view hierarchy.
enum RecentsHeroLayout {
    // MARK: - Looping

    /// How many copies of the items a looping carousel lays out. It starts in the middle copy and
    /// re-centres near either end (see `recenteredSlot`). The row is lazy, so copies cost nothing
    /// until they scroll into view.
    static let loopCopies = 50

    /// Whether the carousel loops. With three items showing at once, looping fewer than three
    /// would put the same item on both sides of the centre.
    static func isLooping(count: Int) -> Bool {
        count >= 3
    }

    static func slotCount(count: Int) -> Int {
        isLooping(count: count) ? count * loopCopies : max(count, 0)
    }

    static func itemIndex(forSlot slot: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((slot % count) + count) % count
    }

    static func homeSlot(forIndex index: Int, count: Int) -> Int {
        guard isLooping(count: count) else { return index }
        return count * (loopCopies / 2) + itemIndex(forSlot: index, count: count)
    }

    /// Where to jump once the carousel rests in `slot`: the same item in the middle copy when
    /// `slot` is within a copy of either end. Every copy looks the same, so the jump is invisible.
    static func recenteredSlot(_ slot: Int, count: Int) -> Int {
        guard isLooping(count: count) else { return slot }
        let isNearEnd = slot < count || slot >= slotCount(count: count) - count
        return isNearEnd ? homeSlot(forIndex: slot, count: count) : slot
    }

    static func nextSlot(_ slot: Int, count: Int) -> Int {
        let slots = slotCount(count: count)
        guard slots > 0 else { return 0 }
        return min(max(slot, 0) + 1, slots - 1)
    }

    static func previousSlot(_ slot: Int, count: Int) -> Int {
        let slots = slotCount(count: count)
        guard slots > 0 else { return 0 }
        return max(min(slot, slots - 1) - 1, 0)
    }

    // MARK: - Sizing

    /// A little over a third, so the shrunken neighbours don't leave wide gaps.
    static let itemWidthFraction = 0.36

    static let maximumItemWidth = 280.0

    /// How far the fade runs below the band, into the gap before the list. It ends before the
    /// first section header.
    nonisolated static let fadeBelowBottom = 16.0

    nonisolated static let fadeCurveDepth = 24.0

    /// A parabola from nothing in the middle to `fadeCurveDepth` at either edge. Keep in sync
    /// with the shader in `RecentsHeroFade.metal`.
    nonisolated static func fadeCurveLift(atDistance distance: Double, fromCentreOfWidth width: Double) -> Double {
        guard width > 0 else { return 0 }
        let across = distance / (width / 2)
        return fadeCurveDepth * across * across
    }

    /// Also the distance between neighbours' centres.
    static func itemWidth(forContainerWidth containerWidth: Double) -> Double {
        min(max(containerWidth, 0) * itemWidthFraction, maximumItemWidth)
    }

    // MARK: - Backdrops

    enum Backdrop: Hashable {
        case color(String)
        case photo(URL)
        case neutral
    }

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

    enum TextStyle: Equatable {
        case light
        case dark
    }

    /// A little above the midpoint, because white text stays readable on mid-tones a touch longer
    /// than black does, especially in bold, large type.
    static let darkTextThreshold = 0.6

    /// Perceived brightness from gamma-encoded sRGB components, using the Rec. 601 weights.
    static func luminance(red: Double, green: Double, blue: Double) -> Double {
        0.299 * red + 0.587 * green + 0.114 * blue
    }

    static func textStyle(forLuminance luminance: Double) -> TextStyle {
        luminance > darkTextThreshold ? .dark : .light
    }

    // MARK: - Navigation bar

    /// `barBottom` is where the bar's bottom edge falls in content coordinates: 0 at rest,
    /// negative when pulled down.
    static func hasScrolledUnderBar(barBottom: Double, threshold: Double) -> Bool {
        barBottom > threshold
    }
}
