//
//  LikeButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/05/2025.
//

import SwiftUI

struct LikeButtonView: View {
    let favorites: Favorites
    let cocktail: Cocktail
    
    var body: some View {
        Button(action: {
            if favorites.contains(cocktail) {
                favorites.remove(cocktail)
            } else {
                favorites.add(cocktail)
                #if os(iOS)
                // haptic feedback
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
                #endif
            }
        }) {
            Label("Like", systemImage: favorites.contains(cocktail) ? "heart.fill" : "heart")
                .foregroundStyle(.red)
                .animation(.default, value: favorites.hasEffect)
                .symbolEffect(.bounce.up, value: favorites.hasEffect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LikeButtonView(favorites: Favorites(), cocktail: Cocktail.example)
}
