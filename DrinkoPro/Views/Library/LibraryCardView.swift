//
//  LibraryCardView.swift
//  DrinkoPro
//

import SwiftUI

struct LibraryCardView: View {
    @Environment(\.libraryCardCaptionLines) private var captionLines

    let model: LibraryCardModel
    /// Overrides `LibraryCardModel.showsCardTitle`.
    var alwaysShowsTitle = false

    private var showsTitle: Bool {
        alwaysShowsTitle || model.showsCardTitle
    }

    var body: some View {
        PolaroidFrame {
            // A square window keeps every photo the same size however the caption wraps.
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                        // The artwork is decorative when the caption names the item; when it doesn't (bare book
                        // covers), VoiceOver reads the title instead.
                        .accessibilityRepresentation {
                            if !showsTitle {
                                Text(model.title)
                            }
                        }
                }
                .overlay(alignment: .topTrailing) {
                    if model.isFavorite {
                        LibraryFavoriteBadge()
                            .padding()
                    }
                }
        } caption: {
            VStack(alignment: .leading) {
                // The line count is always reserved, so every card in a row is the same height.
                Text(model.title)
                    .font(.headline)
                    .lineLimit(captionLines, reservesSpace: true)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .opacity(showsTitle ? 1 : 0)
                    .accessibilityHidden(!showsTitle)

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                }
            }
        }
        // One layer, so system effects that fade the card (like the context menu's highlight)
        // don't turn the individual layers see-through.
        .compositingGroup()
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        .contentShape(.rect(cornerRadius: polaroidCornerRadius))
        #if os(iOS)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: polaroidCornerRadius))
        #endif
    }
}

#if DEBUG
#Preview {
    HStack(alignment: .top) {
        LibraryCardView(model: LibraryCardModel(title: "Ice", image: .symbol("cube"), imageContentMode: .fit, progress: 0.3))
        LibraryCardView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit, isFavorite: true))
    }
    .padding()
}

#Preview("One caption line") {
    HStack(alignment: .top) {
        LibraryCardView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit))
        LibraryCardView(
            model: LibraryCardModel(
                title: "Philadelphia Fish House Punch",
                image: .symbol("cup.and.saucer"),
                imageContentMode: .fit
            )
        )
    }
    .environment(\.libraryCardCaptionLines, 1)
    .padding()
}
#endif
