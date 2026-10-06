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

    var body: some View {
        // A fixed aspect ratio keeps every card the same height however the text wraps.
        Color.clear
            .aspectRatio(4 / 5, contentMode: .fit)
            .overlay {
                LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
            }
            .overlay {
                if titleStyle == .blurredBand {
                    // A blurred, lightly washed-out copy of the image fades in behind the title,
                    // so it melts into the photo's white backdrop with no visible edge or tint.
                    // Flatten it onto the card's background first, or the opaque blur darkens the
                    // translucent fill behind symbols and assets into a grey band.
                    LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                        .background(.background.secondary)
                        .compositingGroup()
                        .blur(radius: 6, opaque: true)
                        .overlay(.white.opacity(0.4))
                        .mask(alignment: .bottom) {
                            VStack(spacing: 0) {
                                // Eased stops so the blur creeps in rather than starting at a visible line.
                                LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .black.opacity(0.1), location: 0.3),
                                        .init(color: .black.opacity(0.4), location: 0.6),
                                        .init(color: .black.opacity(0.8), location: 0.85),
                                        .init(color: .black, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: blurFadeHeight)
                                Color.black
                                    .frame(height: solidBlurHeight)
                            }
                        }
                }
            }
            .overlay(alignment: .bottom) {
                switch titleStyle {
                case .glassPill:
                    VStack(alignment: .leading) {
                        if model.showsCardTitle {
                            Text(model.title)
                                .font(.headline)
                                .lineLimit(2)
                                .titlePill()
                        } else {
                            // The artwork is decorative to VoiceOver, so still read the title.
                            Color.clear
                                .frame(height: 0)
                                .accessibilityElement()
                                .accessibilityLabel(model.title)
                        }

                        if let progress = model.progress {
                            LibraryProgressBar(progress: progress)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(pillInset)
                    // The artwork is always light, so keep the glass and text light in Dark Mode too.
                    .environment(\.colorScheme, .light)
                case .blurredBand:
                    VStack(alignment: .leading) {
                        Text(model.title)
                            .font(.headline)
                            .lineLimit(2)

                        if let progress = model.progress {
                            LibraryProgressBar(progress: progress)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        textHeight = height
                    }
                    .padding()
                    // The backdrop is always light, so keep the text dark in Dark Mode too.
                    .environment(\.colorScheme, .light)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        titleHeight = height
                    }
                }
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
