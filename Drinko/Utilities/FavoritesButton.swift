//
//  FavoritesButton.swift
//  Drinko
//
//  Created by Filippo Cilia on 28/04/2023.
//
import SwiftUI

struct FavoritesButton: View {
    @ObservedObject var favorites = Favorites()

    @State private var counter = 0

    var cocktail: Cocktail

    var body: some View {
        Button(action: {
            withAnimation {
                if favorites.contains(cocktail) {
                    favorites.remove(cocktail)
                } else {
                    favorites.add(cocktail)

                    // haptic feedback
                    UINotificationFeedbackGenerator()
                        .notificationOccurred(.success)
                }
            }
        }) {
            DrinkoButtonStyle(symbolName: "heart.fill",
                              text: favorites.contains(cocktail) ?
                              "Remove from favorites" : "Add to favorites",
                              color: .white,
                              background: favorites.contains(cocktail) ?
                              Color.red : Color.blue)
        }
    }
}

struct FavoritesButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesButton(cocktail: .example)
    }
}
