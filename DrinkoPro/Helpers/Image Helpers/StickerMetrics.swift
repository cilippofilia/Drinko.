//
//  StickerMetrics.swift
//  DrinkoPro
//

import Foundation

/// Sizing and tint constants shared by `StickerImageView`, `UserStickerView` and the backdrops
/// that match them. Kept out of the generic `StickerImageView` so they can be read without
/// naming its placeholder type.
enum StickerMetrics {
    /// How much of the frame the sticker fills when it sits on its backdrop.
    static let insetScale = 0.82
    /// How strongly the tint washes over the white backdrop. Kept pale in both appearances so
    /// the sticker's white border and the card's dark title stay readable. The recents hero
    /// band uses the same wash, so its backdrop matches the cards below it.
    static let tintOpacity = 0.3
}
