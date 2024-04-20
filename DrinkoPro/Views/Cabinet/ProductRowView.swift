//
//  ProductRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftUI

struct ProductRowView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var favorites: Favorites
    
    let product: Item
    
    var body: some View {
        NavigationLink(destination: EditProductView(product: product)) {
            HStack {
                Image(systemName: "cart")
                    .foregroundColor(favorites.containsItem(product) ? Color.secondary : Color.clear)
                    .animation(.default, value: favorites.containsItem(product))
                    .symbolEffect(.bounce.up, value: favorites.hasEffect)

                
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
        
        return ProductRowView(favorites: Favorites(), product: Item(name: "Absolut Vodka", detail: "This is to test the detail section of a profuct", madeIn: "", abv: "43", tried: false))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
