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
            contentView
        } detail: {
            detailContent
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search categories")
    }
}

// MARK: VIEWS
extension CabinetView {
    var contentView: some View {
        Group {
            if let selectedCategory {
                productsListView(for: selectedCategory)
            } else {
                selectCategoryPlaceholder
            }
        }
    }

    var selectCategoryPlaceholder: some View {
        ContentUnavailableView(label: {
            Label("Select a Category", systemImage: "cabinet")
        }, description: {
            Text("Choose a category from the sidebar to view its products.")
        })
    }

    func productsListView(for category: Category) -> some View {
        Group {
            if let products = category.products, !products.isEmpty {
                productsList(for: category, products: products)
            } else {
                emptyProductsView(for: category)
            }
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    addProduct(to: category)
                }) {
                    Label("Add Product", systemImage: "plus")
                }
            }
        }
    }

    func productsList(for category: Category, products: [Item]) -> some View {
        List(selection: $selectedProduct) {
            ForEach(products) { product in
                NavigationLink(value: product) {
                    HStack {
                        Text(product.name)
                            .fontWeight(.medium)

                        Spacer()

                        if product.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    FavoriteProductButtonView(product: product)
                        .tint(product.isFavorite ? .red : .blue)
                }
                .contextMenu {
                    FavoriteProductButtonView(product: product)

                    Divider()

                    Button("Delete Product", role: .destructive) {
                        deleteProduct(product, from: category)
                    }
                }
            }
            .onDelete { indexSet in
                deleteProducts(at: indexSet, from: category)
            }
        }
        .listStyle(.inset)
    }

    func emptyProductsView(for category: Category) -> some View {
        ContentUnavailableView(label: {
            Label("No Products", systemImage: "shippingbox")
        }, description: {
            Text("Add your first product to \(category.name)")
        }, actions: {
            Button("Add Product") {
                addProduct(to: category)
            }
            .buttonStyle(.borderedProminent)
        })
    }

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

// MARK: METHODS
extension CabinetView {
    func addProduct(to category: Category) {
        let newProduct = Item(name: "Product Name")
        category.products?.append(newProduct)
        selectedProduct = newProduct
    }

    func deleteProduct(_ product: Item, from category: Category) {
        if selectedProduct?.id == product.id {
            selectedProduct = nil
        }
        category.products?.removeAll { $0.id == product.id }
    }

    func deleteProducts(at offsets: IndexSet, from category: Category) {
        guard var products = category.products else { return }
        let deletedProducts = offsets.map { products[$0] }
        if let selectedProduct, deletedProducts.contains(where: { $0.id == selectedProduct.id }) {
            self.selectedProduct = nil
        }
        products.remove(atOffsets: offsets)
        category.products = products
    }
}

#Preview {
    CabinetView()
}
