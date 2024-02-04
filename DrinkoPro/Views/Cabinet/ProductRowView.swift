//
//  ProductRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftUI

struct ProductRowView: View {
    @Environment(\.modelContext) private var modelContext
    let favoriteProduct: FavoriteProducts
    
    let product: Product
    
    var body: some View {
        NavigationLink(destination: EditProductView(product: product)) {
            HStack {
                if favoriteProduct.contains(product) {
                    Image(systemName: "cart.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)
                        .frame(width: 22, height: 22, alignment: .center)
                        .padding(8)
                        .animation(.easeOut, value: product)
                }
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                                            
                    HStack(spacing: 0) {
                        Text(product.abv)
                        Text("% ABV")
                    }
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return ProductRowView(favoriteProduct: FavoriteProducts(), product: Product(name: "Absolut Vodka", detail: "This is to test the detail section of a profuct", madeIn: "", abv: "43", tried: false))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
