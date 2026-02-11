//
//  CocktailRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(Favorites.self) private var favorites
    @State private var frameSize: CGFloat = 45

    var cocktail: Cocktail

    var body: some View {
        HStack(spacing: sizeClass == .compact ? 10 : 20) {
            if cocktail.glass == "wine" {
                Image(systemName: "wineglass")
                    .imageScale(.large)
                    .frame(maxWidth: frameSize)
                    .accessibilityHidden(true)
            } else if cocktail.glass == "coffee mug" || cocktail.glass == "julep cup" {
                Image("julep")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: frameSize)
                    .accessibilityHidden(true)
            } else if cocktail.glass == "shot" {
                Image("shot")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: frameSize)
                    .scaleEffect(CGSize(width: 0.6, height: 0.6))
                    .accessibilityHidden(true)
            } else {
                Image(cocktail.image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: frameSize)
                    .accessibilityHidden(true)
            }

            Text(cocktail.name)

            Spacer()

            Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                .foregroundStyle(favorites.contains(cocktail) ? Color.red : Color.clear)
                .animation(.default, value: favorites.hasEffect)
                .symbolEffect(.bounce.up, value: favorites.hasEffect)
                .accessibilityHidden(true)
        }
        .frame(height: frameSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(cocktail.name))
        .accessibilityHint(Text("Double tap to view details."))
        .accessibilityValue(favorites.contains(cocktail) ? Text("Favorite") : Text("Not favorite"))
    }
}

#if DEBUG
#Preview {
    CocktailRowView(cocktail: .example)
        .environment(Favorites())
}
#endif
