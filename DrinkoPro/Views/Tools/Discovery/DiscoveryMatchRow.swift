//
//  DiscoveryMatchRow.swift
//  DrinkoPro
//

import SwiftUI

/// A cocktail the Cabinet can make, with its spirit swap underneath when it is a twist.
struct DiscoveryMatchRow: View {
    @Environment(CocktailsViewModel.self) private var viewModel
    @ScaledMetric private var thumbnailSize: CGFloat = 56

    let match: DiscoveryMatch

    var body: some View {
        let model = viewModel.cardModel(for: match.cocktail)

        HStack {
            LibraryImageView(image: model.image, contentMode: model.imageContentMode, showsStickerBackdrop: false)
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(.rect(cornerRadius: imageCornerRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(match.cocktail.name)
                    .font(.headline)

                if let swap = match.swap {
                    Text(swap.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        // Reads the name first, then the swap.
        .accessibilityElement(children: .combine)
    }
}
