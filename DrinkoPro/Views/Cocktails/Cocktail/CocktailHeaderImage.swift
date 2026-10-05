//
//  CocktailHeaderImage.swift
//  DrinkoPro
//

import SwiftUI

/// The artwork behind the cocktail detail header: the drink's sticker, or its photo when
/// it has no sticker.
struct CocktailHeaderImage: View {
    let cocktail: Cocktail

    var body: some View {
        if let stickerURL = cocktail.stickerURL {
            StickerImageView(url: stickerURL, tint: MainSpirit(ingredients: cocktail.ingredients)?.colorName)
                .frame(height: imageFrameHeight)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        } else {
            AsyncImageView(
                image: cocktail.pic,
                frameHeight: imageFrameHeight,
                aspectRatio: .fit
            )
            .background(Color.white)
        }
    }
}
