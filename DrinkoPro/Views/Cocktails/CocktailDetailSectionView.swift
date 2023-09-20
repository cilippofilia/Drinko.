//
//  CocktailDetailSectionView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct CocktailDetailSectionView: View {
    var cocktail: Cocktail
    var text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text)
                .font(.headline)

            if text == "Method" {
                Text(cocktail.method.capitalizingFirstLetter())
            }

            if text == "Glass" {
                Text(cocktail.glass.capitalizingFirstLetter())
            }

            if text == "Garnish" {
                if cocktail.garnish == "-" {
                    Text(cocktail.garnish.capitalized.replacingOccurrences(of: "-", with: "None").capitalizingFirstLetter())
                        .foregroundColor(.secondary)
                } else {
                    Text(cocktail.garnish.capitalizingFirstLetter())
                }
            }

            if text == "Ice" {
                if cocktail.ice == "-" {
                    Text(cocktail.ice.replacingOccurrences(of: "-", with: "None"))
                        .foregroundColor(.secondary)
                } else {
                    Text(cocktail.ice.capitalizingFirstLetter())
                }
            }

            if text == "Extra" {
                if cocktail.extra == "-" {
                    Text(cocktail.extra.replacingOccurrences(of: "-", with: "None"))
                        .foregroundColor(.secondary)
                } else {
                    Text(cocktail.extra.capitalizingFirstLetter())
                }
            }
            Spacer() // spacer pushes the text on the trailing part of the view
        }
    }
}

#Preview {
    CocktailDetailSectionView(cocktail: .example, text: "Extra")
}
