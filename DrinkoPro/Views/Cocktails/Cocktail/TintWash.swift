//
//  TintWash.swift
//  DrinkoPro
//

import SwiftUI

/// The backdrop stickers sit on. A `nil` color leaves it plain white.
struct TintWash: View {
    let tint: String?

    var body: some View {
        Color.white
            .overlay(tint.map { Color($0).opacity(StickerMetrics.tintOpacity) } ?? .clear)
    }
}
