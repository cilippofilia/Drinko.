//
//  LibraryCardView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's grid layout. Also used for the recents deck.
struct LibraryCardView: View {
    let model: LibraryCardModel
    /// Shows the title in a Liquid Glass pill instead of on a blurred band, as on the recents deck.
    /// The pill style leaves out the subtitle.
    var showsTitlePill = false

    /// How far above the text the blur starts fading in.
    @ScaledMetric private var blurFadeHeight: CGFloat = 48
    /// The measured height of the title block, so the blur covers exactly the text plus the fade.
    @State private var titleHeight: CGFloat = 0

    var body: some View {
        // A fixed aspect ratio keeps every card the same height however the text wraps.
        Color.clear
            .aspectRatio(4 / 5, contentMode: .fit)
            .overlay {
                LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
            }
            .overlay {
                // A blurred, lightly washed-out copy of the image fades in behind the title,
                // so it melts into the photo's white backdrop with no visible edge or tint.
                // The title pill brings its own glass, so it needs no blur behind it.
                if !showsTitlePill {
                    LibraryImageView(image: model.image, contentMode: model.imageContentMode, insetsFittedPhoto: true)
                        .blur(radius: 6, opaque: true)
                        .overlay(.white.opacity(0.4))
                        .mask(alignment: .bottom) {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                                    .frame(height: blurFadeHeight)
                                Color.black
                                    .frame(height: titleHeight)
                            }
                        }
                }
            }
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading) {
                    if showsTitlePill {
                        LibraryTitlePill(title: model.title, font: .headline)
                    } else {
                        Text(model.title)
                            .font(.headline)
                            .lineLimit(2)
                    }

                    if !showsTitlePill, let subtitle = model.subtitle {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                // The title pill sits closer to the corner, so its own corners stay concentric with the card's.
                .padding(.all, showsTitlePill ? LibraryTitlePill.cornerInset : nil)
                // The backdrop is always light, so keep the text dark in Dark Mode too.
                .environment(\.colorScheme, .light)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    titleHeight = height
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
        LibraryCardView(model: LibraryCardModel(title: "Ice", subtitle: "Why ice matters more than you think.", image: .symbol("cube"), imageContentMode: .fit, progress: 0.3))
        LibraryCardView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit, isFavorite: true))
    }
    .padding()
}
#endif
