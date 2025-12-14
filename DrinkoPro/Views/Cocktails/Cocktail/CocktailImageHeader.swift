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
        AsyncImageView(
            image: cocktail.pic,
            frameHeight: imageFrameHeight,
            aspectRatio: .fit
        )
        .containerRelativeFrame(.horizontal) { length, axis in
            sizeClass == .compact ? length * 0.9 : length * 0.7
        }
        .background(Color.white)
        .clipShape(.rect(cornerRadius: imageCornerRadius))
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
