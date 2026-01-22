//
//  MacProductView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 21/01/2026.
//

import SwiftUI

struct MacProductView: View {
    let products: [Item]
    let color: String
    let addProductAction: () -> Void

    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(products) { item in
                NavigationLink(value: item) {
                    Text(item.name)
                        .padding()
                        .frame(width: 80, height: 80)
                        .background(Color(color))
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Button(action: addProductAction) {
                Label("Add Product", systemImage: "plus")
                    .labelStyle(.iconOnly)
                    .frame(width: 80, height: 80)
                    .background(Color(color).opacity(0.3))
                    .clipShape(.rect(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}
#Preview {
    MacProductView(products: [], color: "", addProductAction: { })
}
