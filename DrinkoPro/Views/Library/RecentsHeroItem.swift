//
//  RecentsHeroItem.swift
//  DrinkoPro
//

import SwiftUI

/// No title, because the hero text already names the centred item.
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
