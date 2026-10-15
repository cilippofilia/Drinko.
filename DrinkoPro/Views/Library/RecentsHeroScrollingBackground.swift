//
//  RecentsHeroScrollingBackground.swift
//  DrinkoPro
//

import SwiftUI

/// `RecentsHeroBackground` driven by the carousel's scroll position.
///
/// It is the only view that reads `RecentsHeroScrollState.fractionalSlot`, so each frame of a
/// swipe redraws the backdrop alone rather than the whole band. With Reduce Motion the
/// fraction snaps to the nearer backdrop and the change is animated, so the band cross-fades
/// instead of drifting with the finger.
struct RecentsHeroScrollingBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let scrollState: RecentsHeroScrollState
    /// One backdrop per item.
    let backdrops: [RecentsHeroLayout.Backdrop]

    /// How far above the band the backdrop reaches: more than the navigation bar, large title
    /// and search field together, with room for a long pull-down.
    private let extensionAbove: CGFloat = 600

    var body: some View {
        let position = RecentsHeroLayout.itemPosition(
            forFractionalSlot: scrollState.fractionalSlot,
            itemCount: backdrops.count,
            snapsFraction: reduceMotion
        )
        let fraction = position?.fraction ?? 0
        // Padding by a negative amount makes the backdrop taller than the band without
        // affecting layout, so it reaches behind the navigation bar and over a pull-down. The
        // mask fades the bottom out into the page background (black in dark mode, white in
        // light mode), so the band melts into the list instead of ending on a hard edge.
        RecentsHeroBackground(
            lower: position.map { backdrops[$0.lowerIndex] } ?? .neutral,
            upper: position.map { backdrops[$0.upperIndex] } ?? .neutral,
            fraction: fraction
        )
        .mask {
            VStack(spacing: 0) {
                Rectangle()
                RecentsHeroFadeMask()
                    .frame(height: RecentsHeroLayout.backdropFadeHeight)
            }
        }
        .padding(.top, -extensionAbove)
        .animation(reduceMotion ? .easeInOut : nil, value: fraction)
    }
}
