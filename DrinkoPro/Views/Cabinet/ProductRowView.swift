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
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @ScaledMetric private var minRowHeight: CGFloat = 45

    let product: Item
    var isSelected: Bool = false
    var onSelect: () -> Void = {}

    /// Only highlight the selection while the detail column is on screen beside the sidebar.
    /// On compact widths the detail is pushed over the sidebar and the selection is never
    /// cleared on the way back, so a highlight there would stick to the last item opened.
    private var showsSelection: Bool {
        #if os(iOS)
        isSelected && horizontalSizeClass == .regular
        #else
        isSelected
        #endif
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Label("Need to buy", systemImage: "cart")
                    .foregroundStyle(product.isFavorite ? Color.secondary : Color.clear)
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
                    .foregroundStyle(Color.secondary)
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
            .frame(minHeight: minRowHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .listRowBackground(showsSelection ? Color.accentColor.opacity(0.15) : nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(product.name)
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(showsSelection ? .isSelected : [])
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
