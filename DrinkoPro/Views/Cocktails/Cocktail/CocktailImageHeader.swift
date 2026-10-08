//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

/// The cocktail's artwork with its name on a Liquid Glass pill in the bottom corner, like
/// the library cards. User cocktails have no artwork, so it shows nothing for them.
struct CocktailImageHeader: View {
    let cocktail: Cocktail

    /// The gap between the name pill and the header's edges. Kept below the corner radius
    /// so the pill's corners can follow the header's.
    @ScaledMetric private var pillInset: CGFloat = 8

    var body: some View {
        if !cocktail.isUserCreated {
            CocktailHeaderImage(cocktail: cocktail)
                .overlay(alignment: .bottomLeading) {
                    Text(cocktail.name)
                        .font(.title.bold())
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .titlePill()
                        .padding(pillInset)
                        // The artwork is always light, so keep the glass and text light in Dark Mode too.
                        .environment(\.colorScheme, .light)
                        .accessibilityAddTraits(.isHeader)
                }
                // Rounded like the library cards, so the name pill follows the same corner.
                .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
                // Lets the name pill's corners follow the header's.
                .containerShape(.rect(cornerRadius: libraryCardCornerRadius))
        }
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
