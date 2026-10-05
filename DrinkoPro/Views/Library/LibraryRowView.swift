//
//  LibraryRowView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's list layout.
struct LibraryRowView: View {
    @ScaledMetric private var thumbnailSize: CGFloat = 56

    let model: LibraryCardModel

    var body: some View {
        HStack {
            VStack {
                // Stickers stand on their own in a row, so they can fill the whole thumbnail.
                LibraryImageView(image: model.image, contentMode: model.imageContentMode, showsStickerBackdrop: false)
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipShape(.rect(cornerRadius: imageCornerRadius))

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                        .frame(width: thumbnailSize)
                }
            }

            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.headline)

                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            if model.isFavorite {
                LibraryFavoriteBadge()
            }
        }
        .padding()
        .contentShape(.rect)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        LibraryRowView(model: LibraryCardModel(title: "Ice", subtitle: "Why ice matters more than you think.", image: .symbol("cube"), imageContentMode: .fit, progress: 0.5))
        LibraryRowView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit, isFavorite: true))
    }
}
#endif
