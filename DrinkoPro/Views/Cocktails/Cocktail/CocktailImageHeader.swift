//
//  CocktailImageHeader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

/// The cocktail's artwork with its name laid over a blurred band at the bottom, like the
/// library cards. User cocktails have no artwork, so it shows nothing for them.
struct CocktailImageHeader: View {
    let cocktail: Cocktail

    /// How far above the name the blur starts fading in.
    @ScaledMetric private var blurFadeHeight: CGFloat = 48
    /// The measured height of the name, so the blur covers exactly the text plus the fade.
    @State private var titleHeight: CGFloat = 0

    var body: some View {
        if !cocktail.id.hasPrefix("user-") {
            CocktailHeaderImage(cocktail: cocktail)
                .overlay {
                    // A blurred, lightly washed-out copy of the image fades in behind the name,
                    // so it melts into the artwork's light backdrop with no visible edge or tint.
                    // Flatten the sticker and its backdrop into one clipped layer first, or the
                    // opaque blur treats them separately and smears the sticker into a grey box.
                    CocktailHeaderImage(cocktail: cocktail)
                        .clipped()
                        .compositingGroup()
                        .blur(radius: 6, opaque: true)
                        .overlay(.white.opacity(0.4))
                        .mask(alignment: .bottom) {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                                    .frame(height: blurFadeHeight)
                                Color.black
                                    .frame(height: titleHeight)
                            }
                        }
                        .accessibilityHidden(true)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(cocktail.name)
                        .font(.title.bold())
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        // The backdrop is always light, so keep the text dark in Dark Mode too.
                        .environment(\.colorScheme, .light)
                        .accessibilityAddTraits(.isHeader)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            titleHeight = height
                        }
                }
                .clipShape(.rect(cornerRadius: imageCornerRadius))
        }
    }
}

#if DEBUG
#Preview {
    CocktailImageHeader(cocktail: .example)
}
#endif
