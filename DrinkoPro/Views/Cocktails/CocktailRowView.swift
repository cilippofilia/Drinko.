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
    var spacing: CGFloat {
        #if os(iOS)
        return sizeClass == .compact ? 10 : 20
        #elseif os(macOS)
        return 5
        #endif
    }

    var body: some View {
        HStack(spacing: spacing) {
            if cocktail.glass == "wine" {
                Image(systemName: "wineglass")
                    .imageScale(.large)
                    .frame(maxWidth: frameSize)
            } else if cocktail.glass == "coffee mug" || cocktail.glass == "julep cup" {
                Image("julep")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: frameSize)
            } else if cocktail.glass == "shot" {
                Image("shot")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: frameSize)
                    .scaleEffect(CGSize(width: 0.6, height: 0.6))
            } else {
                Image(cocktail.image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: frameSize)
            }

            Text(cocktail.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .frame(height: frameSize)
        .overlay(alignment: .trailing) {
            Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                .foregroundStyle(favorites.contains(cocktail) ? Color.red : Color.clear)
                .animation(.default, value: favorites.hasEffect)
                .symbolEffect(.bounce.up, value: favorites.hasEffect)
        }
    }
}

#if DEBUG
#Preview {
    CocktailRowView(cocktail: .example)
        .environment(Favorites())
}
#endif
