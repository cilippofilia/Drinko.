//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

struct CocktailImageHeader: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let cocktail: Cocktail
    
    var body: some View {
        if !cocktail.id.hasPrefix("user-") {
            AsyncImageView(
                image: cocktail.pic,
                frameHeight: imageFrameHeight,
                aspectRatio: .fit,
                accessibilityLabel: "Photo of \(cocktail.name)"
            )
            .frame(width: screenWidth * (sizeClass == .compact ? 0.9 : 0.7))
            .background(Color.white)
            .clipShape(.rect(cornerRadius: imageCornerRadius))
        }
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
