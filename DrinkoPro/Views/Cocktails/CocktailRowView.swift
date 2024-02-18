//
//  CocktailRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var favorites = Favorites()
    @State private var frameSize: CGFloat = 45

    var cocktail: Cocktail

    var body: some View {
        NavigationLink(destination: CocktailDetailView(favorites: favorites, cocktail: cocktail)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
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

                Spacer()

                Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                    .foregroundColor(favorites.contains(cocktail) ? Color.red : Color.clear)
                    .animation(.default, value: favorites.hasEffect)
                    .symbolEffect(.bounce.up, value: favorites.hasEffect)
            }
        }
        .frame(height: frameSize)
    }
}

#if DEBUG
#Preview {
    CocktailRowView(cocktail: .example)
        .environmentObject(Favorites())
}
#endif
