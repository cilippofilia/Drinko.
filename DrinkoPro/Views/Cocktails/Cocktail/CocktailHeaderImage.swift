//
//  CocktailHeaderImage.swift
//  DrinkoPro
//

import SwiftUI

/// The artwork behind the cocktail detail header: the drink's sticker, its photo when it has
/// no sticker, or a prompt to add a photo for cocktails without a picture.
struct CocktailHeaderImage: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    let cocktail: Cocktail
    /// Room to leave at the bottom for the name drawn over the header.
    var bottomInset: CGFloat = 0

    var body: some View {
        if !cocktail.hasPicture {
            ContentUnavailableView {
                Label("No Photo", systemImage: "photo.badge.plus")
            } description: {
                Text("Add a photo of your cocktail to show it here.")
            }
            .padding(.bottom, bottomInset)
            .frame(maxWidth: .infinity, minHeight: imageFrameHeight)
            .background(.fill.quaternary)
        } else {
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
}
