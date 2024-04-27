//
//  TipJarView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2024.
//

import StoreKit
import SwiftUI

struct TipJarView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        ScrollView {
            ProductView(id: storeManager.tipsIds.last ?? "") {
                Image(storeManager.tipsIds.last ?? "")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.background.secondary,
                        in: .rect(cornerRadius: 20, style: .continuous))
            .productViewStyle(.large)
            
            ForEach(storeManager.tipsIds.dropLast(), id: \.self) { tip in
                ProductView(id: tip) {
                    Image(tip)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background.secondary,
                            in: .rect(cornerRadius: 20, style: .continuous))
            }
            .navigationTitle("Tip Jar")
            .navigationBarTitleDisplayMode(.inline)
            
            Spacer()
                .frame(height: 50)
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(.background.secondary)
    }
}

#Preview {
    NavigationStack {
        TipJarView()
            .background(.background.secondary,
                        in: .rect(cornerRadius: 20, style: .continuous))
            .environmentObject(StoreManager())
    }
}
