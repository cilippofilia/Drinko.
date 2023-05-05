//
//  CocktailDetailSectionView.swift
//  Drinko
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct CocktailDetailSectionView: View {
    var cocktail: Cocktail
    var text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(text):")
                .font(.headline)

//      MARK: METHOD LINE
            if text.lowercased() == "method" {
                Text(cocktail.method.capitalizingFirstLetter())
            }

//      MARK: GLASS LINE
            if text.lowercased() == "glass" {
                Text(cocktail.glass.capitalizingFirstLetter())
            }

//      MARK: GARNISH LINE
            if text.lowercased() == "garnish" {
                if cocktail.garnish == "-" {
                    Text(cocktail.garnish.capitalized.replacingOccurrences(of: "-", with: "None").capitalizingFirstLetter())
                        .foregroundColor(.secondary)
                } else {
                    Text(cocktail.garnish.capitalizingFirstLetter())
                }
            }

//      MARK: ICE LINE & EXTRA
            if text.lowercased() == "ice" {
                if cocktail.ice == "-" {
                    Text(cocktail.ice.replacingOccurrences(of: "-", with: "None"))
                        .foregroundColor(.secondary)
                } else {
                    Text(cocktail.ice.capitalizingFirstLetter())
                }
            }

//      MARK: EXTRA LINE
            if text.lowercased() == "extra" {
                if cocktail.extra == "-" {
                    Text(cocktail.extra.replacingOccurrences(of: "-", with: "None"))
                        .foregroundColor(.secondary)
                } else {
                    Text(cocktail.extra.capitalizingFirstLetter())
                }
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct CocktailDetailSectionView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailDetailSectionView(cocktail: .example, text: "Extra")
    }
}
