//
//  ProductRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftData
import SwiftUI

struct ProductRowView: View {
    @Environment(\.modelContext) private var modelContext
    @ScaledMetric private var minRowHeight: CGFloat = 45
    
    let product: Item
    
    var body: some View {
        NavigationLink(destination: EditProductView(product: product)) {
            HStack {
                Label("Need to buy", systemImage: "cart")
                    .foregroundColor(product.isFavorite ? Color.secondary : Color.clear)
                    .animation(.default, value: product.isFavorite)
                    .symbolEffect(.bounce.up, value: product.isFavorite)
                    .labelStyle(.iconOnly)
                    .padding(.trailing, 4)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(product.name)

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
        .frame(minHeight: minRowHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(product.name)
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        var details = [String]()
        if product.isFavorite {
            details.append("Need to buy")
        }
        if !product.abv.isEmpty {
            details.append("\(product.abv)% ABV")
        }
        if !product.madeIn.isEmpty {
            details.append("Made in \(product.madeIn)")
        }
        if product.tried {
            details.append("Rated \(product.rating) out of 5")
        }
        return details.joined(separator: ", ")
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()
        
        return ProductRowView(product: Item(name: "Absolut Vodka", detail: "This is to test the detail section of a product", madeIn: "Portugal", abv: "43", tried: true, isFavorite: false))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
