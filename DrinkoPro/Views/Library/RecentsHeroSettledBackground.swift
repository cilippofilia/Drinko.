//
//  RecentsHeroSettledBackground.swift
//  DrinkoPro
//

import SwiftUI

/// Only changes once a swipe ends, so scrolling never redraws it.
struct RecentsHeroSettledBackground: View {
    let backdrop: RecentsHeroLayout.Backdrop
    let fadeAboveBottom: Double

    /// More than the navigation bar and search field together, with room for a long pull-down.
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
        // Negative padding makes the backdrop taller than the band without affecting layout. The
        // fade sits inside the padding so it measures the whole extended backdrop.
        .visualEffect { [fadeAboveBottom] content, proxy in
            content.colorEffect(
                ShaderLibrary.recentsHeroBackdropFade(
                    .float(proxy.size.height - RecentsHeroLayout.fadeBelowBottom - fadeAboveBottom),
                    .float(proxy.size.height),
                    .float(proxy.size.width),
                    .float(RecentsHeroLayout.fadeCurveDepth)
                )
            )
        }
        .padding(.top, -extensionAbove)
        .padding(.bottom, -RecentsHeroLayout.fadeBelowBottom)
    }
}
