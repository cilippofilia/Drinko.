//
//  CrossPromoBannerModifier.swift
//  DrinkoPro
//

import SwiftUI

/// Uses `.safeAreaInset(edge:)` rather than `.safeAreaBar(edge:)`, which would extend the scroll
/// edge effect up to the banner and dim the content behind it.
///
/// The content is stretched to fill the space first, or on content that sizes itself (such as
/// a `ContentUnavailableView`) the banner would hang just below it instead of at the bottom.
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
    func crossPromoBanner() -> some View {
        modifier(CrossPromoBannerModifier())
    }
}
