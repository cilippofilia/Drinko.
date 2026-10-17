//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

struct CocktailImageHeader: View {
    /// The system appearance, read outside the polaroid (which is always light), so the History
    /// sheet still follows it.
    @Environment(\.colorScheme) private var colorScheme

    let cocktail: Cocktail
    let history: History?

    var body: some View {
        PolaroidFrame {
            CocktailHeaderImage(cocktail: cocktail)
        } caption: {
            // The icons sit on the name's last line, so they read as part of the title.
            HStack(alignment: .lastTextBaseline) {
                Text(cocktail.name)
                    .font(.title.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)

                CocktailHeaderActions(cocktail: cocktail, history: history, sheetColorScheme: colorScheme)
            }
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
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
