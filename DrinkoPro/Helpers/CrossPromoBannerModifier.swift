//
//  CrossPromoBannerModifier.swift
//  DrinkoPro
//

import SwiftUI

/// Attaches the persistent cross-promo ad banner to the bottom of a view.
///
/// Uses `.safeAreaBar(edge:)` on iOS 26 / macOS 26 and later, which lets the banner sit on top of
/// scrollable content with the modern Liquid Glass treatment, falling back to
/// `.safeAreaInset(edge:)` on earlier OS versions.
private struct CrossPromoBannerModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content
                .safeAreaBar(edge: .bottom) {
                    CrossPromoBannerView()
                }
        } else {
            content
                .safeAreaInset(edge: .bottom) {
                    CrossPromoBannerView()
                }
        }
    }
}

extension View {
    /// Pins a `CrossPromoBannerView` to the bottom of this view's safe area.
    func crossPromoBanner() -> some View {
        modifier(CrossPromoBannerModifier())
    }
}
