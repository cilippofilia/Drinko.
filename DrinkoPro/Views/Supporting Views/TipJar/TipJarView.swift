//
//  TipJarView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/08/2023.
//

#warning("👨‍💻 Update paywall by using RevenueCats newest issue.")

import StoreKit
import SwiftUI

struct TipJarView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var products: [Product] = []

    let productIDs = ["SmallTip","MediumTip","BigTip","GenerousTip","ExtremelyGenerousTip"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Support the developer by giving him a tip!\nJust like you would do to a bartender when you got get some drinks at a night out. 😉")
                    .font(.headline)
                    .padding(.top, 10)

                ForEach(purchaseManager.products, id: \.self) { tip in
                    DrinkoButtonView(title: "\(tip.displayPrice) - \(tip.displayName)",
                                     icon: nil) {
                        Task {
                            do {
                                try await purchaseManager.purchase(tip)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(width: compactScreenWidth)
            .navigationTitle("Tip Jar")
            .task {
                do {
                    try await purchaseManager.loadProducts()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    TipJarView()
        .environmentObject(PurchaseManager())
}
