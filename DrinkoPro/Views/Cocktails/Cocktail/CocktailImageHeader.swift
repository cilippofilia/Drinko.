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
    @Environment(CocktailsViewModel.self) private var viewModel

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

    @Environment(\.colorScheme) private var colorScheme

    /// Pictures are always light, so the name and icons stay dark over them in Dark Mode too.
    /// Without a picture the header follows the system appearance.
    private var titleColorScheme: ColorScheme {
        viewModel.hasPicture(cocktail) ? .light : colorScheme
    }

    var body: some View {
        CocktailHeaderImage(cocktail: cocktail, bottomInset: rowHeight)
            .overlay {
                if viewModel.hasPicture(cocktail) {
                    LibraryCardBlurBand(fadeHeight: blurFadeHeight, solidHeight: solidBlurHeight)
                }
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
                        .environment(\.colorScheme, titleColorScheme)
                        .accessibilityAddTraits(.isHeader)

                    CocktailHeaderActions(cocktail: cocktail, history: history, iconColorScheme: titleColorScheme)
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
