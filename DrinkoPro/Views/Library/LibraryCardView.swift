//
//  LibraryCardView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's grid layout. Also used for the recents deck.
struct LibraryCardView: View {
    @Environment(\.libraryCardCaptionLines) private var captionLines

    let model: LibraryCardModel
    /// Shows the title even when the model hides it on bare grid artwork (book covers that
    /// already show their title). The recents deck sets this, since its smaller cards benefit
    /// from a consistent label across items.
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
                        // The artwork is decorative when the caption names the item. When it
                        // doesn't (bare book covers), replace its accessibility tree with the
                        // title so VoiceOver still reads it; otherwise leave it as the empty tree
                        // `LibraryImageView`'s own `.accessibilityHidden(true)` already produces.
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
                // The library's line count is always reserved, so every card in a row is the
                // same height; a name too long for it shrinks a little before it truncates. A
                // book cover already shows its title, so its caption is left blank, like an
                // unwritten polaroid.
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
        // Flatten the paper, photo and caption into one layer, so system effects that dim or
        // fade the card (like the context menu's long-press highlight) don't turn the
        // individual layers see-through.
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
