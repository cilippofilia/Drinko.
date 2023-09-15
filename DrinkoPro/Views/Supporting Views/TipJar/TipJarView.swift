//
//  TipJarView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/08/2023.
//

import StoreKit
import SwiftUI

struct TipJarView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var products: [Product] = []

    let productIDs = ["SmallTip","MediumTip","BigTip","GenerousTip","ExtremelyGenerousTip"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Support the developer by giving him a tip! Just like you would do to a bartender when you got get some drinks at a night out. 😉")
                    .font(.headline)
                    .padding(.top, 10)

                ForEach(purchaseManager.products) { (tip) in
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

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TipJarView()
                .environmentObject(UnlockManager(dataController: DataController()))
        }
    }
}
