//
//  FavoriteProductButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct FavoriteProductButtonView: View {
    let favorites: FavoriteProducts
    let product: Product

    var body: some View {
        Button(action: {
            if favorites.contains(product) {
                favorites.remove(product)
            } else {
                favorites.add(product)
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }) {
            Label(favorites.contains(product) ? "Remove from Cart" : "Add to Cart", systemImage: "cart")
        }
        .animation(.default, value: favorites.hasEffect)
    }
}

#Preview {
    FavoriteProductButtonView(favorites: FavoriteProducts(), product: Product(name: "Test"))
}
