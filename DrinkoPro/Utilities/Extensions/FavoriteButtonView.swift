//
//  FavoriteButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/01/2024.
//

import SwiftUI

struct FavoriteButtonView: View {
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
            Image(systemName: favorites.contains(cocktail) ?
                  "heart.slash" : "heart")
            Text("Like")
        }
    }
}

#Preview {
    FavoriteButtonView(favorites: Favorites(), cocktail: .example)
}
