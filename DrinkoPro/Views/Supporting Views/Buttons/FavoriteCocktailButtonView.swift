//
//  FavoriteCocktailButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/01/2024.
//

import SwiftUI

struct FavoriteCocktailButtonView: View {
    let favorites: Favorites
    let cocktail: Cocktail

    var body: some View {
        Button(action: {
            if favorites.containsCocktail(cocktail) {
                favorites.removeCocktail(cocktail)
            } else {
                favorites.addCocktail(cocktail)
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }) {
            Label("Like", systemImage: "heart")
        }
        .animation(.default, value: favorites.hasEffect)
        .symbolEffect(.bounce.up, value: favorites.hasEffect)
    }
}

#Preview {
    FavoriteCocktailButtonView(favorites: Favorites(), cocktail: .example)
}
