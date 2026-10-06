//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

/// The cocktail's artwork with its name laid over a blurred band at the bottom, like the
/// library cards. User cocktails have no artwork, so it shows nothing for them.
struct CocktailImageHeader: View {
    let cocktail: Cocktail

    /// How far above the name the blur starts fading in.
    @ScaledMetric private var blurFadeHeight: CGFloat = 28
    /// The measured height of the name, so the blur reaches full strength right where the text starts.
    @State private var textHeight: CGFloat = 0

    /// The gap between the name and the card's leading edge, and between its baseline and
    /// the card's bottom edge, so the name sits evenly in the corner.
    private let titleInset: CGFloat = 16

    /// The fully blurred area: the name plus the inset below it.
    private var solidBlurHeight: CGFloat {
        textHeight + titleInset
    }

    var body: some View {
        if !cocktail.id.hasPrefix("user-") {
            CocktailHeaderImage(cocktail: cocktail)
                .overlay {
                    // A blurred, lightly washed-out copy of the image fades in behind the name,
                    // so it melts into the artwork's light backdrop with no visible edge or tint.
                    // Flatten the sticker and its backdrop into one clipped layer first, or the
                    // opaque blur treats them separately and smears the sticker into a grey box.
                    CocktailHeaderImage(cocktail: cocktail)
                        .clipped()
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
                        .accessibilityHidden(true)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(cocktail.name)
                        .font(.title.bold())
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            textHeight = height
                        }
                        .padding(titleInset)
                        // Measure the bottom inset from the baseline rather than below the
                        // descenders, or the name looks further from the bottom than the side.
                        .alignmentGuide(.bottom) { dimensions in
                            dimensions[.lastTextBaseline] + titleInset
                        }
                        // The backdrop is always light, so keep the text dark in Dark Mode too.
                        .environment(\.colorScheme, .light)
                        .accessibilityAddTraits(.isHeader)
                }
                .clipShape(.rect(cornerRadius: imageCornerRadius))
        }
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
