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
            if favorites.contains(cocktail) {
                favorites.remove(cocktail)
            } else {
                favorites.add(cocktail)
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

#if DEBUG
#Preview {
    FavoriteCocktailButtonView(favorites: Favorites(), cocktail: .example)
}
#endif
