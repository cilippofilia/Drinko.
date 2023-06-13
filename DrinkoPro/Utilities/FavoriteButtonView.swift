//
//  FavoriteButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 01/06/2023.
//

import SwiftUI

struct FavoriteButtonView: View {
    var favorites: Favorites
    var cocktail: Cocktail

    var body: some View {
        Button(action: {
            if favorites.contains(cocktail) {
                favorites.remove(cocktail)

            } else {
                favorites.add(cocktail)

                // haptic feedback
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }) {
            Image(systemName: "heart")
            // Deep press-Context button text
            Text(favorites.contains(cocktail) ? "Remove from favorites" : "Add to favorites")
        }
    }
}

#if DEBUG
struct FavoriteButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButtonView(favorites: Favorites(), cocktail: .example)
    }
}
#endif
