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
        #if os(iOS)
        .frame(width: screenWidth * (sizeClass == .compact ? 0.9 : 0.7))
        #elseif os(macOS)
        .padding(.horizontal, 20)
        #endif
        .background(Color.white)
        .clipShape(.rect(cornerRadius: imageCornerRadius))
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
