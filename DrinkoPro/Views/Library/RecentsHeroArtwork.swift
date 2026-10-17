//
//  RecentsHeroArtwork.swift
//  DrinkoPro
//

import SwiftUI

/// The shadows are deliberately small: every item re-renders them on each frame of a swipe.
struct RecentsHeroArtwork: View {
    let model: LibraryCardModel

    var body: some View {
        switch model.image {
        case .sticker(let url, _):
            StickerImageView(url: url, showsBackdrop: false)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        case .userSticker(let id, let revision, _):
            UserStickerView(id: id, revision: revision, showsBackdrop: false)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        case .remote, .asset, .symbol, .userPhoto, .glass:
            // Cocktails with tinted glass have no picture, so the hero excludes them; if one
            // does get here it sits in a rounded card like any other non-sticker.
            LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                .clipShape(.rect(cornerRadius: libraryCardCornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
    }
}
