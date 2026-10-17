//
//  ShareCardArtworkView.swift
//  DrinkoPro
//

import SwiftUI

struct ShareCardArtworkView: View {
    let artwork: ShareCardArtwork

    /// Matches `StickerMetrics.insetScale`.
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
        case .userPhoto(let image):
            Image(decorative: image, scale: 1)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
    }
}
