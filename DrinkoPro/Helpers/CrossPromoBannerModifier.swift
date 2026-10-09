//
//  CrossPromoBannerModifier.swift
//  DrinkoPro
//

import SwiftUI

/// Attaches the persistent cross-promo ad banner to the bottom of a view.
///
/// Uses `.safeAreaInset(edge:)` rather than `.safeAreaBar(edge:)`: a safe-area bar counts as a
/// bar, so the system extends the scroll edge effect up to the banner's top edge and dims the
/// content behind it. As an inset, the banner floats as its own card over the content and only
/// the tab bar casts the edge effect, matching pages without a banner.
private struct CrossPromoBannerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
    }
}

extension View {
    /// Pins a `CrossPromoBannerView` to the bottom of this view's safe area.
    func crossPromoBanner() -> some View {
        modifier(CrossPromoBannerModifier())
    }
}
