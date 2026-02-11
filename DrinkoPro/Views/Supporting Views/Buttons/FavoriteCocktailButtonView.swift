//
//  FavoriteCocktailButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/01/2024.
//

import SwiftUI

struct FavoriteCocktailButtonView: View {
    @Environment(Favorites.self) private var favorites
    let cocktail: Cocktail

    var body: some View {
        Button(action: {
            if favorites.contains(cocktail) {
                favorites.remove(cocktail)
            } else {
                favorites.add(cocktail)
                #if os(iOS)
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
                #endif
            }
        }) {
            Label(
                favorites.contains(cocktail) ? "Remove Favorite" : "Add Favorite",
                systemImage: favorites.contains(cocktail) ? "heart.fill" : "heart"
            )
        }
        .accessibilityLabel(favorites.contains(cocktail) ? "Remove from favorites" : "Add to favorites")
        .animation(.default, value: favorites.hasEffect)
        .symbolEffect(.bounce.up, value: favorites.hasEffect)
        .accessibilityLabel(favorites.contains(cocktail) ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint(cocktail.name)
    }
}

#if DEBUG
#Preview {
    FavoriteCocktailButtonView(cocktail: .example)
}
#endif
