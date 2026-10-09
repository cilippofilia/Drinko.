//
//  CabinetView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftData
import SwiftUI

struct CabinetView: View {
    @Environment(\.modelContext) private var modelContext
    #if os(iOS)
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    #endif

    @State private var showAddCategorySheet: Bool = false
    @State private var selectedProduct: Item?
    @State private var selectedCategory: Category?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            Group {
                if categories.isEmpty {
                    unavailableView
                } else {
                    categoriesList
                }
            }
            .navigationTitle("Cabinet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Category", systemImage: "plus") {
                        showAddCategorySheet.toggle()
                    }
                }
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView()
                    .presentationDetents([.medium, .large])
            }
            #if os(iOS)
            .crossPromoBanner()
            #endif
        } detail: {
            detailView
        }
    }
}

// MARK: VIEWS
extension CabinetView {
    var unavailableView: some View {
        ContentUnavailableView(label: {
            Label("Empty Cabinet", systemImage: "cabinet.fill")
        }, description: {
            Text("To start, press 'Add a category' below or the + button at the top of the view.")
        }, actions: {
            Button("Add a category") {
                showAddCategorySheet.toggle()
            }
        })
    }

    var categoriesList: some View {
        List {
            ForEach(categories) { category in
                Section {
                    if let products = category.products {
                        ForEach(products) { product in
                            ProductRowView(
                                product: product,
                                isSelected: selectedProduct == product,
                                onSelect: { select(product) }
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                FavoriteProductButtonView(product: product)
                                    .tint(product.isFavorite ? .red : .blue)
                            }
                        }
                    }
                    Button("Add Product", systemImage: "plus") {
                        addProduct(to: category)
                    }
                } header: {
                    CategoryHeaderView(category: category, onEdit: { edit(category) })
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    var detailView: some View {
        if let selectedProduct {
            NavigationStack {
                EditProductView(product: selectedProduct, onDelete: { clearSelection(after: selectedProduct) })
            }
            .id(selectedProduct.id)
        } else if let selectedCategory {
            NavigationStack {
                EditCategoryView(category: selectedCategory, onDelete: { clearSelection(after: selectedCategory) })
            }
            .id(selectedCategory.id)
        } else {
            // Hosted in a stack like the selected states, so the detail column's bar
            // (and the sidebar toggle in it) sits under the tab bar the same way.
            NavigationStack {
                ContentUnavailableView(
                    "Select a Product",
                    systemImage: "cabinet",
                    description: Text("Choose a product or category to edit it.")
                )
            }
        }
    }

    func addProduct(to category: Category) {
        category.products?.append(Item(name: "Product Name"))
        #if os(iOS)
        crossPromoSignal.bump()
        #endif
    }

    /// Opens `product` in the detail column, pushing it on compact widths.
    func select(_ product: Item) {
        selectedProduct = product
        selectedCategory = nil
        preferredCompactColumn = .detail
    }

    /// Opens `category` for editing in the detail column, pushing it on compact widths.
    func edit(_ category: Category) {
        selectedCategory = category
        selectedProduct = nil
        preferredCompactColumn = .detail
    }

    /// Clears the selection once `product` has been deleted, so the detail column doesn't
    /// keep showing a model that's gone, then returns to the sidebar on compact widths.
    func clearSelection(after product: Item) {
        if selectedProduct == product {
            selectedProduct = nil
            preferredCompactColumn = .sidebar
        }
    }

    /// Clears the selection once `category` has been deleted, so the detail column doesn't
    /// keep showing a model that's gone, then returns to the sidebar on compact widths.
    /// Also drops a selected product that belonged to the deleted category.
    func clearSelection(after category: Category) {
        if selectedCategory == category {
            selectedCategory = nil
            preferredCompactColumn = .sidebar
        }
        if let selectedProduct, selectedProduct.category == category {
            self.selectedProduct = nil
            preferredCompactColumn = .sidebar
        }
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return CabinetView()
        /// comment the following line to display an emptyCabinet
            .modelContainer(previewer.container)
            .environment(RemoveAdsStore())
            .environment(CrossPromoSignal())
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
