//
//  ContentView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 23/12/2025.
//

import SwiftUI

struct ContentView: View {
    let selectedCategory: Binding<Category?>
    let selectedProduct: Binding<Item?>

    var body: some View {
        Group {
            if let category = selectedCategory.wrappedValue {
                productsListView(for: category)
            } else {
                selectCategoryPlaceholder
            }
        }
    }
}

// MARK: Views
private extension ContentView {
    func productsListView(for category: Category) -> some View {
        Group {
            if let products = category.products, !products.isEmpty {
                productsList(for: category, products: products)
            } else {
                emptyProductsView(for: category)
            }
        }
    }

    func productsList(for category: Category, products: [Item]) -> some View {
        List(selection: selectedProduct) {
            ForEach(products) { product in
                NavigationLink(value: product) {
                    HStack {
                        HStack {
                            if product.isFavorite {
                                Image(systemName: "cart")
                            }

                            Text(product.name)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        if product.tried {
                            HStack(spacing: 2) {
                                Text("\(product.rating, specifier: "%.1f")")
                                Image(systemName: "star.fill")
                            }
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        }
                    }
                    .frame(height: 45)
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

            Button(action: {
                addProduct(to: category)
            }) {
                Label("Add Item", systemImage: "plus")
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
    }

    var selectCategoryPlaceholder: some View {
        ContentUnavailableView(label: {
            Label("Select a Category", systemImage: "cabinet")
        }, description: {
            Text("Choose a category from the sidebar to view its products.")
        })
    }

    func emptyProductsView(for category: Category) -> some View {
        ContentUnavailableView(label: {
            Label("No Items", systemImage: "shippingbox")
        }, description: {
            Text("Add your first item to \(category.name)")
        }, actions: {
            Button(action: {
                addProduct(to: category)
            }) {
                Label("Add Item", systemImage: "plus")
            }
        })
    }
}

// MARK: Methods
private extension ContentView {
    func addProduct(to category: Category) {
        let newProduct = Item(name: "Product Name")
        category.products?.append(newProduct)
        selectedProduct.wrappedValue = newProduct
    }

    func deleteProduct(_ product: Item, from category: Category) {
        if selectedProduct.wrappedValue?.id == product.id {
            selectedProduct.wrappedValue = nil
        }
        category.products?.removeAll { $0.id == product.id }
    }

    func deleteProducts(at offsets: IndexSet, from category: Category) {
        guard var products = category.products else { return }
        let deletedProducts = offsets.map { products[$0] }
        let selectedProduct = selectedProduct
        if deletedProducts.contains(where: { $0.id == selectedProduct.wrappedValue?.id }) {
            self.selectedProduct.wrappedValue = nil
        }
        products.remove(atOffsets: offsets)
        category.products = products
    }

}

#Preview {
    ContentView(selectedCategory: .constant(nil), selectedProduct: .constant(nil))
}
