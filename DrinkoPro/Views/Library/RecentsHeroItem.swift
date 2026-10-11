//
//  RecentsHeroItem.swift
//  DrinkoPro
//

import SwiftUI

/// One item in `RecentsHeroView`'s carousel: a bare picture with no title, because the hero
/// text above the row already names whichever item is centred.
///
/// Stickers float on the band with no card or backdrop, so the cut-out shape is the item and
/// the shadow follows its outline. Everything else (photos, book covers, symbols, assets) is
/// kept in a rounded card, with the corner radius the rest of the library uses, because
/// without a frame a rectangular photo would look cut off.
struct RecentsHeroItem: View {
    let model: LibraryCardModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            artwork
                .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.libraryCard)
    }

    @ViewBuilder
    private var artwork: some View {
        switch model.image {
        case .sticker(let url, _):
            // `showsBackdrop: false` lets the sticker fill its frame on its own.
            StickerImageView(url: url, showsBackdrop: false)
                .shadow(color: .black.opacity(0.3), radius: 14, y: 8)
        default:
            LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                .clipShape(.rect(cornerRadius: libraryCardCornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        }
    }
}
