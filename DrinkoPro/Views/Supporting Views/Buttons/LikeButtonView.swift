//
//  LikeButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/05/2025.
//

import SwiftUI

struct LikeButtonView: View {
    @Environment(Favorites.self) private var favorites
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
        #if os(iOS)
        .buttonStyle(.plain)
        #endif
    }
}

#if DEBUG
#Preview {
    LikeButtonView(cocktail: Cocktail.example)
}
#endif
