//
//  WidgetStickerBackdrop.swift
//  DrinkoWidget
//

import SwiftUI

/// The widget's background: white washed with the main spirit's color, the same backdrop the
/// app's library cards put behind a sticker.
struct WidgetStickerBackdrop: View {
    /// A color asset name. `nil` leaves the backdrop plain white.
    let tint: String?

    var body: some View {
        Color.white
            .overlay(tint.map { Color($0).opacity(StickerMetrics.tintOpacity) } ?? .clear)
    }
}
