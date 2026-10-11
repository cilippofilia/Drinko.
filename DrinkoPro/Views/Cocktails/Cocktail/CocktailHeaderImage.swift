//
//  CocktailHeaderImage.swift
//  DrinkoPro
//

import SwiftUI

/// The artwork behind the cocktail detail header: the drink's sticker, its photo when it has
/// no sticker, or its glass on a tint wash for the user's own cocktails.
struct CocktailHeaderImage: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    let cocktail: Cocktail

    var body: some View {
        switch viewModel.cardModel(for: cocktail).image {
        case .sticker(let url, let tint):
            StickerImageView(url: url, tint: tint)
                .frame(height: imageFrameHeight)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        case .remote:
            AsyncImageView(
                image: cocktail.pic,
                frameHeight: imageFrameHeight,
                aspectRatio: .fit
            )
            .background(Color.white)
        case let artwork:
            TintedGlassArtwork(artwork: artwork, tint: viewModel.stickerTint(for: cocktail))
                .frame(height: imageFrameHeight)
                .frame(maxWidth: .infinity)
        }
    }
}
