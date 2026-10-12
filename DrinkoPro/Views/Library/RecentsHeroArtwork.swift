//
//  RecentsHeroArtwork.swift
//  DrinkoPro
//

import SwiftUI

/// The picture inside a `RecentsHeroItem`.
///
/// Stickers float bare so their shadow follows the cut-out outline; everything else sits in a
/// rounded card. The shadows are deliberately small: every item re-renders them on each frame
/// of a swipe, and large blur radii are expensive to redraw.
struct RecentsHeroArtwork: View {
    let model: LibraryCardModel

    var body: some View {
        switch model.image {
        case .sticker(let url, _):
            // `showsBackdrop: false` lets the sticker fill its frame on its own.
            StickerImageView(url: url, showsBackdrop: false)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        case .userSticker(let id, let revision, _):
            // Drawn exactly like a bundled sticker: bare, with the shadow following the outline.
            UserStickerView(id: id, revision: revision, showsBackdrop: false)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        default:
            LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                .clipShape(.rect(cornerRadius: libraryCardCornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
    }
}
