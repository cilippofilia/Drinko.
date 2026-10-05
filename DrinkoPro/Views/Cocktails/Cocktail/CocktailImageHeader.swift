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
        if let stickerURL = cocktail.stickerURL {
            StickerImageView(url: stickerURL)
                .frame(height: imageFrameHeight)
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: imageCornerRadius))
                .accessibilityHidden(true)
        } else if !cocktail.id.hasPrefix("user-") {
            AsyncImageView(
                image: cocktail.pic,
                frameHeight: imageFrameHeight,
                aspectRatio: .fit
            )
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
