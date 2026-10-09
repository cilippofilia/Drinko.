//
//  CocktailDetailSectionView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

/// A single row inside a cocktail's detail list (its method, glass, garnish, ice, or extra),
/// showing a localized label and the matching value pulled from a `Cocktail`.
struct CocktailDetailSectionView: View {
    enum Kind {
        case method
        case glass
        case garnish
        case ice
        case extra

        /// The localized label shown before the value.
        var title: LocalizedStringKey {
            switch self {
            case .method:
                "Method"
            case .glass:
                "Glass"
            case .garnish:
                "Garnish"
            case .ice:
                "Ice"
            case .extra:
                "Extra"
            }
        }

        /// The raw value pulled from `cocktail` for this detail kind.
        func value(for cocktail: Cocktail) -> String {
            switch self {
            case .method:
                cocktail.method
            case .glass:
                cocktail.glass
            case .garnish:
                cocktail.garnish
            case .ice:
                cocktail.ice
            case .extra:
                cocktail.extra
            }
        }
    }

    var cocktail: Cocktail
    var kind: Kind

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(kind.title)
                .font(.headline)

            if kind.value(for: cocktail) == "-" {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                Text(kind.value(for: cocktail).capitalizingFirstLetter())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    CocktailDetailSectionView(cocktail: .example, kind: .extra)
}
#endif
