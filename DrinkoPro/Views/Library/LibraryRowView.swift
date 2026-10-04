//
//  LibraryRowView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's list layout.
struct LibraryRowView: View {
    @ScaledMetric private var thumbnailSize: CGFloat = 56

    let model: LibraryCardModel
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack {
                LibraryImageView(image: model.image, contentMode: model.imageContentMode)
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
        }
        .padding()
        .background {
            if isSelected {
                Rectangle().fill(.tint.opacity(0.15))
            }
        }
        .contentShape(.rect)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        LibraryRowView(
            model: LibraryCardModel(title: "Ice", subtitle: "Why ice matters more than you think.", image: .symbol("cube"), imageContentMode: .fit, progress: 0.5),
            isSelected: true
        )
        LibraryRowView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit), isSelected: false)
    }
}
#endif
