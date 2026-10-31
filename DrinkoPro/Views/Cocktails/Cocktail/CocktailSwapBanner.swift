//
//  CocktailSwapBanner.swift
//  DrinkoPro
//

import SwiftUI

/// Tells the reader which spirit to swap, when a cocktail was found through cabinet discovery.
struct CocktailSwapBanner: View {
    let swap: SpiritSwap

    var body: some View {
        Label(swap.message, systemImage: "arrow.triangle.swap")
            .font(.headline)
            .padding(detailCardInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.quinary, in: .rect(cornerRadius: libraryCardCornerRadius))
    }
}
