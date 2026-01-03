//
//  FavoriteProductButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct FavoriteProductButtonView: View {
    let product: Item
    let labelText: String

    var body: some View {
        Button(action: {
            product.isFavorite.toggle()
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }) {
            Label(labelText, systemImage: "cart")
        }
        .animation(.default, value: product.isFavorite)
    }
}

#if DEBUG
#Preview {
    FavoriteProductButtonView(product: Item(name: "Test"), labelText: "test")
}
#endif
