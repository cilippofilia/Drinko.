//
//  ProductRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftUI

struct ProductRowView: View {
    @Environment(\.modelContext) private var modelContext
    
    let product: Item
    
    var body: some View {
        NavigationLink(destination: EditProductView(product: product)) {
            HStack {
                Image(systemName: "cart")
                    .foregroundColor(product.isFavorite ? Color.secondary : Color.clear)
                    .animation(.default, value: product.isFavorite)
                    .symbolEffect(.bounce.up, value: product.isFavorite)

                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                                    
                    HStack(spacing: 0) {
                        if product.abv != "" {
                            Text(product.abv)
                            Text("% ABV")
                        }
                        if product.abv != "" && product.madeIn != "" {
                            Text("-")
                                .padding(.horizontal, 4)
                        }
                        if product.madeIn != "" {
                            Text(product.madeIn)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()

                if product.tried {
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(product.rating)")
                        Image(systemName: "star.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(Color(.drGold))
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return ProductRowView(product: Item(name: "Absolut Vodka", detail: "This is to test the detail section of a product", madeIn: "Portugal", abv: "43", tried: true, isFavorite: false))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
