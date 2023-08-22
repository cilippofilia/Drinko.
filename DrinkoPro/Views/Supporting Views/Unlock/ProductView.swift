//
//  ProductView.swift
//  Drinko
//
//  Created by Filippo Cilia on 24/04/2021.
//

import StoreKit
import SwiftUI

struct ProductView: View {
    @EnvironmentObject var unlockManager: UnlockManager
    let product: SKProduct

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Get Unlimited Products")
                    .font(.headline)
                    .padding(.top, 10)

                Text("You can add up to 3 product categories and 9 items in total, or pay \(product.localizedPrice) to add as many as you want.")
                Text("If you already have bought the Cabinet+ version on another device, press 'Restore Purchases'.")
                    .font(.caption)

                Button("Buy: \(product.localizedPrice)", action: unlock)
                    .buttonStyle(PurchaseButton())

                Button("Restore Purchases", action: unlockManager.restore)
                    .buttonStyle(PurchaseButton())
            }
        }
    }

    func unlock() {
        unlockManager.buy(product: product)
    }
}
