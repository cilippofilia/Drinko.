//
//  FavoriteProductButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct FavoriteProductButtonView: View {
    let product: Item

    var body: some View {
        Button(action: {
            product.isFavorite.toggle()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }) {
            Label(product.isFavorite ? "Remove from Cart" : "Add to Cart", systemImage: "cart")
        }
        .animation(.default, value: product.isFavorite)
    }
}

#if DEBUG
#Preview {
    FavoriteProductButtonView(product: Item(name: "Test"))
}
#endif
