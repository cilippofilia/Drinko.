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

    /// When set, the page shows only this category (an iPad sidebar row). `nil` shows all.
    private let categoryID: UUID?

    @State private var showAddCategorySheet: Bool = false
    @State private var selectedProduct: Item?
    @State private var selectedCategory: Category?

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    init(categoryID: UUID? = nil) {
        self.categoryID = categoryID
    }

    private var visibleCategories: [Category] {
        categories.filter { categoryID == nil || $0.id == categoryID }
    }

    private var title: String {
        if let categoryID, let category = categories.first(where: { $0.id == categoryID }) {
            return category.name
        }
        return String(localized: "Cabinet")
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleCategories.isEmpty {
                    unavailableView
                } else {
                    categoriesList
                }
            }
            .navigationTitle(title)
            .toolbar {
                if categoryID == nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add Category", systemImage: "plus") {
                            showAddCategorySheet.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView()
                    .presentationDetents([.medium, .large])
            }
            .navigationDestination(item: $selectedProduct) { product in
                EditProductView(product: product, onDelete: { clearSelection(after: product) })
            }
            .navigationDestination(item: $selectedCategory) { category in
                EditCategoryView(category: category, onDelete: { clearSelection(after: category) })
            }
            #if os(iOS)
            .crossPromoBanner()
            #endif
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
            ForEach(visibleCategories) { category in
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

    func addProduct(to category: Category) {
        category.products?.append(Item(name: "Product Name"))
        #if os(iOS)
        crossPromoSignal.bump()
        #endif
    }

    /// Pushes `product` onto the stack.
    func select(_ product: Item) {
        selectedProduct = product
        selectedCategory = nil
    }

    /// Pushes `category` onto the stack for editing.
    func edit(_ category: Category) {
        selectedCategory = category
        selectedProduct = nil
    }

    /// Pops `product` once it's been deleted, so the stack doesn't keep showing a model
    /// that's gone.
    func clearSelection(after product: Item) {
        if selectedProduct == product {
            selectedProduct = nil
        }
    }

    /// Pops `category` once it's been deleted, so the stack doesn't keep showing a model
    /// that's gone. Also drops a selected product that belonged to the deleted category.
    func clearSelection(after category: Category) {
        if selectedCategory == category {
            selectedCategory = nil
        }
        if let selectedProduct, selectedProduct.category == category {
            self.selectedProduct = nil
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
