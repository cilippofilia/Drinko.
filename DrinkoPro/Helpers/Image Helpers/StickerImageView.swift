//
//  StickerImageView.swift
//  DrinkoPro
//

import SwiftUI

/// A cocktail sticker, either on its own or inset on a light backdrop.
struct StickerImageView<Failure: View>: View {
    @Environment(\.stickerBackdropCornerRadius) private var backdropCornerRadius
    let url: URL?
    /// Sits the sticker inset on a backdrop. Without it, the sticker fills the frame on its own.
    var showsBackdrop = true
    /// A color asset name to wash the backdrop with. `nil` leaves it plain white.
    var tint: String?
    private let failureContent: Failure

    /// Shows `failure` in place of the sticker when it can't be loaded, e.g. offline.
    init(url: URL?, showsBackdrop: Bool = true, tint: String? = nil, @ViewBuilder failure: () -> Failure) {
        self.url = url
        self.showsBackdrop = showsBackdrop
        self.tint = tint
        self.failureContent = failure()
    }

    var body: some View {
        CachedRemoteImage(url: url, contentMode: .fit) { failureContent }
            .scaleEffect(showsBackdrop ? StickerMetrics.insetScale : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if showsBackdrop {
                    Color.white
                        .overlay(tint.map { Color($0).opacity(StickerMetrics.tintOpacity) } ?? .clear)
                }
            }
            // Only the backdrop needs rounding. A bare sticker fills its frame, so rounding
            // would clip the corners of its die-cut outline.
            .clipShape(.rect(cornerRadius: showsBackdrop ? backdropCornerRadius : 0, style: .continuous))
    }
}

extension StickerImageView where Failure == ImageFailedToLoad {
    init(url: URL?, showsBackdrop: Bool = true, tint: String? = nil) {
        self.init(url: url, showsBackdrop: showsBackdrop, tint: tint) { ImageFailedToLoad() }
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
