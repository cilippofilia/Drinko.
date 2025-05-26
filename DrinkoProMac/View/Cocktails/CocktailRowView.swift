//
//  CocktailRowView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 25/05/2025.
//

import SwiftUI

struct CocktailRowView: View {
    let cocktail: Cocktail
    let favorites: Favorites

    var body: some View {
        HStack {
            if cocktail.glass == "wine" {
                Image(systemName: "wineglass")
                    .imageScale(.large)
                    .frame(maxWidth: 45)
            } else if cocktail.glass == "coffee mug" || cocktail.glass == "julep cup" {
                Image("julep")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 45)
            } else if cocktail.glass == "shot" {
                Image("shot")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 45)
                    .scaleEffect(CGSize(width: 0.6, height: 0.6))
            } else {
                Image(cocktail.image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 45)
            }

            Text(cocktail.name)

            Spacer()

            Image(systemName: favorites.contains(cocktail) ? "heart.fill" : "heart")
                .foregroundColor(favorites.contains(cocktail) ? Color.red : Color.clear)
                .animation(.default, value: favorites.hasEffect)
                .symbolEffect(.bounce.up, value: favorites.hasEffect)
        }
        .frame(height: 45)
        .tag(cocktail)
        .contentShape(Rectangle())
    }
}

#Preview {
    CocktailRowView(cocktail: Cocktail.example, favorites: Favorites())
}
