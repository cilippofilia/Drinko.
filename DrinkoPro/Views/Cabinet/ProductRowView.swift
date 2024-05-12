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

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return ProductRowView(product: Item(name: "Absolut Vodka", detail: "This is to test the detail section of a profuct", madeIn: "", abv: "43", tried: false, isFavorite: false))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
