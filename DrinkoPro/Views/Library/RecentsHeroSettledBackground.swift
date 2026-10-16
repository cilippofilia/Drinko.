//
//  RecentsHeroSettledBackground.swift
//  DrinkoPro
//

import SwiftUI

/// The recents hero band's backdrop for the item the carousel has settled on.
///
/// The backdrop only changes once a swipe ends, then cross-fades to the new item's,
/// so scrolling (however fast) never redraws it. It reaches far above the band, behind the
/// navigation bar and over a pull-down, and fades out at the bottom into the page background.
struct RecentsHeroSettledBackground: View {
    @Environment(\.layoutDirection) private var layoutDirection

    let backdrop: RecentsHeroLayout.Backdrop
    /// How far above the band's bottom edge the backdrop starts fading out.
    let fadeAboveBottom: Double

    /// How far above the band the backdrop reaches: more than the navigation bar, large title
    /// and search field together, with room for a long pull-down.
    private let extensionAbove: CGFloat = 600

    var body: some View {
        // Giving each backdrop its own identity cross-fades whole backdrops, photos included,
        // rather than swapping a photo in place once it loads.
        ZStack {
            RecentsHeroBackground(backdrop: backdrop)
                .id(backdrop)
                .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.25), value: backdrop)
        // Padding by a negative amount makes the backdrop taller than the band without
        // affecting layout, so it reaches behind the navigation bar and over a pull-down, and
        // past the bottom edge into the gap before the list. A shader fades its bottom out into
        // the page background (black in dark mode, white in light mode) along a gentle curve, so
        // the band melts into the list instead of ending on a hard edge. The effect sits inside the padding so it
        // measures the whole extended backdrop.
        //
        // The backdrop also runs sideways behind a vertical toolbar (iPhone Duo), so the curve is
        // centred on the band itself, between the safe-area insets, to stay in line with the
        // items riding along it.
        .visualEffect { [fadeAboveBottom, layoutDirection] content, proxy in
            let insets = proxy.safeAreaInsets
            let isRightToLeft = layoutDirection == .rightToLeft
            let left = isRightToLeft ? insets.trailing : insets.leading
            let right = isRightToLeft ? insets.leading : insets.trailing
            let bandWidth = max(proxy.size.width - left - right, 0)
            return content.colorEffect(
                ShaderLibrary.recentsHeroBackdropFade(
                    .float(proxy.size.height - RecentsHeroLayout.fadeBelowBottom - fadeAboveBottom),
                    .float(proxy.size.height),
                    .float(left + bandWidth / 2),
                    .float(bandWidth / 2),
                    .float(RecentsHeroLayout.fadeCurveDepth)
                )
            )
        }
        .padding(.top, -extensionAbove)
        .padding(.bottom, -RecentsHeroLayout.fadeBelowBottom)
    }
}
