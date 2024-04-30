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
    
    var blurStyle: UIBlurEffect.Style = .dark

    var body: some View {
        ScrollView {
            VStack {
                Text("Want to go the extra mile?")
                    .font(.title2)
                    .bold()
                Text("Join _Drinko Premium_ and unlock more content, new app icons and unlimited Categories and Products inside your Cabinet!")
                    .multilineTextAlignment(.center)

                ForEach(storeManager.subsIds, id: \.self) { product in
                    ProductView(id: product) {
                        Image(product)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        return UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

#Preview {
    NavigationStack {
        PremiumView()
            .environmentObject(StoreManager())
    }
}
