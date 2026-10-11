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
            RecentsHeroArtwork(model: model)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    if model.isFavorite {
                        RecentsHeroFavoriteBadge()
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.default, value: model.isFavorite)
        }
        .buttonStyle(.libraryCard)
    }
}
