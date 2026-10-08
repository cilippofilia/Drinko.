//
//  LibraryCardView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's grid layout. Also used for the recents deck.
struct LibraryCardView: View {
    let model: LibraryCardModel
    var titleStyle: LibraryCardTitleStyle = .glassPill

    /// The gap between the title pill and the card's edges.
    @ScaledMetric private var pillInset: CGFloat = 8

    /// How far above the text the blur starts fading in.
    @ScaledMetric private var blurFadeHeight: CGFloat = 28
    /// The measured height of the padded title block.
    @State private var titleHeight: CGFloat = 0
    /// The measured height of the text alone, so the blur reaches full strength right where the text starts.
    @State private var textHeight: CGFloat = 0

    /// The fully blurred area: the text plus the padding below it. The padding is even,
    /// so the space above the text is half the difference between the two heights.
    private var solidBlurHeight: CGFloat {
        (titleHeight + textHeight) / 2
    }

    /// `true` when the title isn't drawn anywhere on the card's own layers, so VoiceOver
    /// needs to read it from the artwork instead.
    private var artworkNeedsTitleLabel: Bool {
        titleStyle == .glassPill && !model.showsCardTitle
    }

    var body: some View {
        // A fixed aspect ratio keeps every card the same height however the text wraps.
        Color.clear
            .aspectRatio(4 / 5, contentMode: .fit)
            .overlay {
                LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                    // The artwork is decorative when the title's drawn elsewhere on the card.
                    // When it isn't (bare book covers), replace its accessibility tree with the
                    // title so VoiceOver still reads it; otherwise leave it as the empty tree
                    // `LibraryImageView`'s own `.accessibilityHidden(true)` already produces.
                    .accessibilityRepresentation {
                        if artworkNeedsTitleLabel {
                            Text(model.title)
                        }
                    }
            }
            .overlay {
                if titleStyle == .blurredBand {
                    LibraryCardBlurBand(fadeHeight: blurFadeHeight, solidHeight: solidBlurHeight)
                }
            }
            .overlay(alignment: .bottom) {
                LibraryCardTitleOverlay(
                    model: model,
                    titleStyle: titleStyle,
                    pillInset: pillInset,
                    textHeight: $textHeight,
                    titleHeight: $titleHeight
                )
            }
            .overlay(alignment: .topTrailing) {
                if model.isFavorite {
                    LibraryFavoriteBadge()
                        .padding()
                }
            }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
        // Lets the title pill's corners follow the card's.
        .containerShape(.rect(cornerRadius: libraryCardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: libraryCardCornerRadius)
                .strokeBorder(.separator, lineWidth: 1)
        }
        // Flatten the stacked image, blur and text into one layer, so system effects that
        // dim or fade the card (like the context menu's long-press highlight) don't turn
        // the individual layers see-through.
        .compositingGroup()
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .contentShape(.rect(cornerRadius: libraryCardCornerRadius))
        #if os(iOS)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: libraryCardCornerRadius))
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
#endif
