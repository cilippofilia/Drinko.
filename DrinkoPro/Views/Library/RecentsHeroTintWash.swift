//
//  RecentsHeroTintWash.swift
//  DrinkoPro
//

import SwiftUI

/// The tint layer of `RecentsHeroBackground`: the backdrops' tints washed over the base at the
/// sticker cards' strength, so the band at rest matches its card exactly.
///
/// Neighbouring tints blend as the band moves between them; next to an untinted backdrop the
/// one tint fades in or out.
struct RecentsHeroTintWash: View {
    let lower: Color?
    let upper: Color?
    /// 0 shows `lower`; 1 shows `upper`.
    let fraction: Double

    var body: some View {
        switch (lower, upper) {
        case let (lowerTint?, upperTint?):
            lowerTint.mix(with: upperTint, by: fraction)
                .opacity(StickerImageView.tintOpacity)
        case let (lowerTint?, nil):
            lowerTint.opacity(StickerImageView.tintOpacity * (1 - fraction))
        case let (nil, upperTint?):
            upperTint.opacity(StickerImageView.tintOpacity * fraction)
        case (nil, nil):
            Color.clear
        }
    }
}
