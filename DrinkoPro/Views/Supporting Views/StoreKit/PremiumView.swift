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
    @EnvironmentObject var storeManager: StoreManager
        
    var body: some View {
        ScrollView {
            VStack {
                Text("Want to go the extra mile?")
                    .font(.title2)
                    .bold()
                Text("Join _Drinko Premium_ and unlock more content, new app icons and unlimited Categories and Products inside your Cabinet!")
                    .multilineTextAlignment(.center)
                
                ProductView(id: storeManager.subsIds[0]) {
                    Image(systemName: "rainbow")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.multicolor)
                        .symbolEffect(.variableColor.reversing, options: .repeating, isActive: true)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.background.secondary,
                            in: .rect(cornerRadius: 20, style: .continuous))
                .productViewStyle(.large)
                
                ForEach(storeManager.subsIds.dropFirst().reversed(), id: \.self) { product in
                    ProductView(id: product) {
                        Image(systemName: "rainbow")
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.multicolor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background.secondary,
                                in: .rect(cornerRadius: 20, style: .continuous))
                }
                
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
                
                Button(action: {
                    storeManager.restoreSubscription()
                }) {
                    Text("Restore Purchases")
                }
                .padding(.vertical)
            }
            .padding(.vertical)
            .frame(width: compactScreenWidth)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                do {
                    try await storeManager.loadTipsProducts()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(.background.secondary)
    }
}

#Preview {
    NavigationStack {
        PremiumView()
            .environmentObject(StoreManager())
    }
}
