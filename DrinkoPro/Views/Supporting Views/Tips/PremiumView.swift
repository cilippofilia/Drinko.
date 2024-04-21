//
//  PremiumView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/08/2023.
//

import StoreKit
import SwiftUI

struct PremiumView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var storeManager = StoreManager()
    
    var products: [Product] {
        storeManager.sortByPrice(storeManager.products)
    }
    var tips: [Product] {
        storeManager.returnTips(products)
    }
    var subs: [Product] {
        storeManager.returnSubs(products)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("Do you like Drinko. ?")
                        .font(.title2)
                        .bold()
                    Text("Consider living a tip! 😉")
                }
                .padding(.vertical)
                
                ForEach(tips, id: \.self) { tip in
                    DrinkoButtonView(
                        title: "\(tip.displayPrice) - \(tip.displayName)",
                        icon: nil
                    ) {
                        storeManager.purchaseProduct(tip)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: 420)
                }
                                
                    VStack {
                        Text("Want to go the extra mile?")
                            .font(.title2)
                            .bold()
                        Text("Join _Drinko Premium_ and unlock more content, new app icons and unlimited Categories and Products inside your Cabinet!")
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical)
                    
                    ForEach(subs, id: \.self) { sub in
                        DrinkoButtonView(
                            title: "\(sub.displayPrice) - \(sub.displayName)",
                            icon: nil
                        ) {
                            storeManager.purchaseProduct(sub)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: 420)
                    }

                    Button(action: {
                        storeManager.restoreSubscription()
                    }) {
                        Text("Restore Purchases")
                    }
                    .padding()
                
                
                if storeManager.hasUnlockedPro {
                    VStack {
                        Text("Thank you for being a")
                        
                        Text("✨ Premium Member ✨")
                            .font(.title2)
                            .bold()
                            .italic()
                    }
                    .padding(.vertical)
                }
            }
            .padding(.vertical)
            .frame(width: compactScreenWidth)
            .navigationTitle("Tip Jar")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                do {
                    try await storeManager.loadTipsProducts()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    PremiumView()
        .environment(StoreManager())
}
