//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

/// The cocktail's artwork with its name on a blurred band in the bottom corner, like the
/// library cards, and the Favorite/History buttons in the opposite corner.
struct CocktailImageHeader: View {
    let cocktail: Cocktail
    let history: History?

    /// How far above the name the blur starts fading in.
    @ScaledMetric private var blurFadeHeight: CGFloat = 28
    /// The measured height of the padded name-and-buttons row.
    @State private var rowHeight: CGFloat = 0
    /// The measured height of the name text alone, so the blur reaches full strength right
    /// where the name starts.
    @State private var textHeight: CGFloat = 0

    /// The fully blurred area: the name plus the padding below it. The padding is even,
    /// so the space above the name is half the difference between the two heights.
    private var solidBlurHeight: CGFloat {
        (rowHeight + textHeight) / 2
    }

    var body: some View {
        CocktailHeaderImage(cocktail: cocktail)
            .overlay {
                LibraryCardBlurBand(fadeHeight: blurFadeHeight, solidHeight: solidBlurHeight)
            }
            .overlay(alignment: .bottom) {
                // The icons sit on the name's last line, so they read as part of the title.
                HStack(alignment: .lastTextBaseline) {
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
                        // The artwork is always light, so keep the name dark in Dark Mode too.
                        .environment(\.colorScheme, .light)
                        .accessibilityAddTraits(.isHeader)

                    CocktailHeaderActions(cocktail: cocktail, history: history)
                }
                .padding()
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    rowHeight = height
                }
            }
            // Rounded like the library cards.
            .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
    }
}

#if DEBUG
#Preview("Bundled") {
    CocktailImageHeader(cocktail: .example, history: .example)
        .padding()
        .drinkoPreviewEnvironment()
}

#Preview("User cocktail, no history") {
    CocktailImageHeader(cocktail: .userCreatedExample, history: nil)
        .padding()
        .drinkoPreviewEnvironment()
}

#Preview("Long name") {
    CocktailImageHeader(
        cocktail: Cocktail(
            id: "user-long",
            name: "The Extraordinarily Long Named Midnight Garden Fizz",
            method: "build",
            glass: "collins",
            garnish: "-",
            ice: "cubes",
            extra: "-",
            ingredients: []
        ),
        history: .example
    )
    .padding()
    .drinkoPreviewEnvironment()
}
#endif
