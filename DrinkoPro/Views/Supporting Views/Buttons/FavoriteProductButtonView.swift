//
//  FavoriteProductButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct FavoriteProductButtonView: View {
    let favorites: Favorites
    let product: Item

    var body: some View {
        Button(action: {
            if favorites.containsItem(product) {
                favorites.removeItem(product)
            } else {
                favorites.addItem(product)
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }) {
            Label(favorites.containsItem(product) ? "Remove from Cart" : "Add to Cart", systemImage: "cart")
        }
        .animation(.default, value: favorites.hasEffect)
    }
}

#Preview {
    FavoriteProductButtonView(favorites: Favorites(), product: Item(name: "Test"))
}
