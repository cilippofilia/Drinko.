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
    var isFavorite: Bool {
       return favorites.contains(cocktail)
    }

    var body: some View {
        Button(action: {
            if isFavorite {
                favorites.remove(cocktail)
            } else {
                favorites.add(cocktail)
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }) {
            Label("Like", systemImage: isFavorite ? "heart.slash.fill" : "heart")
        }
        .animation(.default, value: favorites.hasEffect)
        .symbolEffect(.bounce.up, value: favorites.hasEffect)
    }
}

#if DEBUG
#Preview {
    FavoriteCocktailButtonView(cocktail: .example)
}
#endif
