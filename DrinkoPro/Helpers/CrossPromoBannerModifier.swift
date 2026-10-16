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
///
/// The content is stretched to fill the available space first: an inset sits at the bottom of
/// the view it's attached to, so on content that sizes itself (such as a `ContentUnavailableView`
/// empty state) the banner would otherwise hang just below it instead of at the page's bottom.
private struct CrossPromoBannerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
