//
//  CocktailHeaderImage.swift
//  DrinkoPro
//

import SwiftUI

/// The artwork behind the cocktail detail header: the drink's sticker, the user's sticker or photo
/// when it has one, or a prompt to add a photo for cocktails without a picture.
struct CocktailHeaderImage: View {
    @Environment(CocktailsViewModel.self) private var viewModel

    let cocktail: Cocktail

    var body: some View {
        if !viewModel.hasPicture(cocktail) {
            ContentUnavailableView {
                Label("No Photo", systemImage: "photo.badge.plus")
            } description: {
                Text("Add a photo of your cocktail to show it here.")
            } actions: {
                CocktailPhotoMenu(
                    onPick: { viewModel.setPhoto($0, for: cocktail) },
                    label: { Label("Add Photo", systemImage: "photo.badge.plus") }
                )
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, minHeight: imageFrameHeight, alignment: .center)
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
            case .userPhoto(let id, let revision):
                UserPhotoView(id: id, revision: revision)
                    .frame(height: imageFrameHeight)
                    .frame(maxWidth: .infinity)
            case .userSticker(let id, let revision, let tint):
                UserStickerView(id: id, revision: revision, tint: tint)
                    .frame(height: imageFrameHeight)
                    .frame(maxWidth: .infinity)
            case .asset, .symbol, .glass:
                // Only cocktails without a picture get glass art, and they take the branch above.
                EmptyView()
            }
        }
    }
}
