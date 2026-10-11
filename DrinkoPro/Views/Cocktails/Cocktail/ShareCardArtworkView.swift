//
//  ShareCardArtworkView.swift
//  DrinkoPro
//

import SwiftUI

/// Draws a `ShareCardArtwork` filling its container.
struct ShareCardArtworkView: View {
    let artwork: ShareCardArtwork

    /// How much of the banner a sticker fills, matching `StickerImageView`.
    private let stickerInsetScale = 0.82

    var body: some View {
        switch artwork {
        case .sticker(let image, let tint):
            Image(decorative: image, scale: 1)
                .resizable()
                .scaledToFit()
                .scaleEffect(stickerInsetScale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { TintWash(tint: tint) }
        case .photo(let image):
            Image(decorative: image, scale: 1)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
        case .glass(let glass, let tint):
            TintedGlassArtwork(artwork: glass, tint: tint)
        }
    }
}
