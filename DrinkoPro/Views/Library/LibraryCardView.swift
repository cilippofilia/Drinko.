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
                Text(model.title)
                    .font(.headline)
                    .lineLimit(2)

                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
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
                .strokeBorder(.tint, lineWidth: 2)
                .opacity(isSelected ? 1 : 0)
        }
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
