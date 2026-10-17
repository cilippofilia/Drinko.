//
//  TintWash.swift
//  DrinkoPro
//

import SwiftUI

/// White washed with a pale tint of the named color asset — the backdrop the stickers sit on.
/// `nil` leaves it plain white.
struct TintWash: View {
    let tint: String?

    var body: some View {
        Color.white
            .overlay(tint.map { Color($0).opacity(StickerMetrics.tintOpacity) } ?? .clear)
    }
}
