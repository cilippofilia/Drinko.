//
//  FavoriteProductButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct FavoriteProductButtonView: View {
    #if os(iOS)
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    #endif
    let product: Item

    var body: some View {
        Button(action: {
            product.isFavorite.toggle()
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            if product.isFavorite {
                crossPromoSignal.bump()
            }
            #endif
        }) {
            Label(product.isFavorite ? "Remove from Cart" : "Add to Cart", systemImage: "cart")
        }
        .animation(.default, value: product.isFavorite)
        .accessibilityHint(product.name)
    }
}

#if DEBUG
#Preview {
    FavoriteProductButtonView(product: Item(name: "Test"))
        #if os(iOS)
        .environment(CrossPromoSignal())
        #endif
}
#endif
