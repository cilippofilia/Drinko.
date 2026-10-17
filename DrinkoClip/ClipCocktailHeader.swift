//
//  ClipCocktailHeader.swift
//  DrinkoClip
//

import SwiftUI

/// The cocktail's sticker as a polaroid with its name below, like the full app's header without
/// the photo and history actions.
struct ClipCocktailHeader: View {
    let cocktail: Cocktail

    private var tint: String? {
        MainSpirit(ingredients: cocktail.ingredients)?.colorName
    }

    var body: some View {
        PolaroidFrame {
            StickerImageView(url: cocktail.stickerURL, tint: tint) {
                // Offline, show the glass on the same tinted wash instead of an error.
                TintedGlassArtwork(artwork: cocktail.glassArtwork, tint: tint)
            }
            .frame(height: imageFrameHeight)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
        } caption: {
            Text(cocktail.name)
                .font(.title.bold())
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}
