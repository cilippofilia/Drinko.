//
//  CabinetView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 18/12/2025.
//

import SwiftData
import SwiftUI

struct CabinetView: View {
    static let cabinetTag: String? = "Cabinet"
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCategory: Category?
    @State private var selectedProduct: Item?
    @State private var showAddCategorySheet: Bool = false
    @State private var searchText: String = ""

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationSplitView {
            SidebarView(
                categories: categories,
                showAddCategorySheet: $showAddCategorySheet,
                searchText: $searchText,
                selectedCategory: $selectedCategory,
                selectedProduct: $selectedProduct
            )
        } content: {
            ContentView(
                selectedCategory: $selectedCategory,
                selectedProduct: $selectedProduct
            )
        } detail: {
            detailContent
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search categories")
    }
}

// MARK: VIEWS
extension CabinetView {
    var detailContent: some View {
        Group {
            if let selectedProduct {
                productDetailView(for: selectedProduct)
            } else {
                selectProductPlaceholder
            }
        }
    }

    var selectProductPlaceholder: some View {
        ContentUnavailableView(label: {
            Label("Select a Product", systemImage: "shippingbox")
        }, description: {
            Text("Choose a product from the list to view its details.")
        })
    }

    func productDetailView(for product: Item) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Product header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: {
                            product.isFavorite.toggle()
                        }) {
                            Image(systemName: product.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(product.isFavorite ? .yellow : .secondary)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                    }
                }

                Divider()

                // Product information sections
                VStack(alignment: .leading, spacing: 16) {
                    infoSection(title: "Details", systemImage: "info.circle") {
                        Text("Product details would go here")
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    infoSection(title: "Statistics", systemImage: "chart.bar") {
                        Text("Product statistics would go here")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    // Edit product action
                }) {
                    Label("Edit Product", systemImage: "pencil")
                }
            }
        }
    }

    func infoSection<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            content()
        }
    }
}

#Preview {
    CabinetView()
}
