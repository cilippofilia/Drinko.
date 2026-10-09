//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

/// The cocktail's artwork with its name on a blurred band in the bottom corner, like the
/// library cards. User cocktails have no artwork, so it shows nothing for them.
struct CocktailImageHeader: View {
    let cocktail: Cocktail

    /// How far above the name the blur starts fading in.
    @ScaledMetric private var blurFadeHeight: CGFloat = 28
    /// The measured height of the padded name block.
    @State private var nameHeight: CGFloat = 0
    /// The measured height of the name text alone, so the blur reaches full strength right
    /// where the name starts.
    @State private var textHeight: CGFloat = 0

    /// The fully blurred area: the name plus the padding below it. The padding is even,
    /// so the space above the name is half the difference between the two heights.
    private var solidBlurHeight: CGFloat {
        (nameHeight + textHeight) / 2
    }

    var body: some View {
        if !cocktail.isUserCreated {
            CocktailHeaderImage(cocktail: cocktail)
                .overlay {
                    LibraryCardBlurBand(fadeHeight: blurFadeHeight, solidHeight: solidBlurHeight)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(cocktail.name)
                        .font(.title.bold())
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            textHeight = height
                        }
                        .padding()
                        // The artwork is always light, so keep the name dark in Dark Mode too.
                        .environment(\.colorScheme, .light)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            nameHeight = height
                        }
                        .accessibilityAddTraits(.isHeader)
                }
                // Rounded like the library cards.
                .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
        }
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
