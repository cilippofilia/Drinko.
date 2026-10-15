//
//  StickerImageView.swift
//  DrinkoPro
//

import SwiftUI

/// A cocktail sticker, either on its own or inset on a light backdrop.
struct StickerImageView: View {
    @Environment(\.stickerBackdropCornerRadius) private var backdropCornerRadius
    let url: URL?
    /// Sits the sticker inset on a backdrop. Without it, the sticker fills the frame on its own.
    var showsBackdrop = true
    /// A color asset name to wash the backdrop with. `nil` leaves it plain white.
    var tint: String?

    /// How much of the frame the sticker fills when it sits on its backdrop. Shared with
    /// `UserStickerView` so the user's stickers sit the same way.
    static let insetScale = 0.82
    /// How strongly the tint washes over the white backdrop. Kept pale in both appearances so
    /// the sticker's white border and the card's dark title stay readable. The recents hero
    /// band uses the same wash, so its backdrop matches the cards below it.
    static let tintOpacity = 0.3

    var body: some View {
        CachedRemoteImage(url: url, contentMode: .fit)
            .scaleEffect(showsBackdrop ? Self.insetScale : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if showsBackdrop {
                    Color.white
                        .overlay(tint.map { Color($0).opacity(Self.tintOpacity) } ?? .clear)
                }
            }
            // Only the backdrop needs rounding. A bare sticker fills its frame, so rounding
            // would clip the corners of its die-cut outline.
            .clipShape(.rect(cornerRadius: showsBackdrop ? backdropCornerRadius : 0, style: .continuous))
    }
}

#if DEBUG
#Preview {
    HStack {
        ForEach(["aperol-spritz", "americano-cocktail", "dry-martini"], id: \.self) { name in
            let base = "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main"
            StickerImageView(url: URL(string: "\(base)/drinko-\(name).png"), tint: MainSpirit.gin.colorName)
                .frame(width: 110, height: 110)
                .clipShape(.rect(cornerRadius: 10))
        }
    }
}
#endif
