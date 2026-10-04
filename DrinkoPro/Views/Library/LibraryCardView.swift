//
//  LibraryCardView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's grid layout. Also used for the recents deck.
struct LibraryCardView: View {
    let model: LibraryCardModel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay {
                    LibraryImageView(image: model.image, contentMode: model.imageContentMode)
                }
                .clipped()

            VStack(alignment: .leading) {
                // Reserve both lines even for short text so every card in the grid
                // (and the recents deck) has the same height.
                Text(model.title)
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)

                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2, reservesSpace: true)
                }

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                }
            }
            .multilineTextAlignment(.leading)
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: libraryCardCornerRadius)
                .strokeBorder(.separator, lineWidth: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: libraryCardCornerRadius)
                .strokeBorder(.tint, lineWidth: 2)
                .opacity(isSelected ? 1 : 0)
        }
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .contentShape(.rect(cornerRadius: libraryCardCornerRadius))
    }
}

#if DEBUG
#Preview {
    HStack(alignment: .top) {
        LibraryCardView(
            model: LibraryCardModel(title: "Ice", subtitle: "Why ice matters more than you think.", image: .symbol("cube"), imageContentMode: .fit, progress: 0.3),
            isSelected: true
        )
        LibraryCardView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit), isSelected: false)
    }
    .padding()
}
#endif
