//
//  CabinetView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftData
import SwiftUI

struct CabinetView: View {
    @Environment(AppNavigationModel.self) private var appNavigationModel
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
        .onAppear(perform: pruneSelection)
        // File › New Category. `initial: true` covers the page created by the tab switch.
        .onChange(of: appNavigationModel.pendingCreation, initial: true) { _, _ in
            presentPendingCreationIfNeeded()
        }
        // On iPad, this page and another live Cabinet page (the main one, or another
        // category's) can both be showing a product or category pushed from the now-stale
        // selection below. Catches a deletion made on the other page.
        .onChange(of: categories.flatMap { [$0.id] + ($0.products ?? []).map(\.id) }) {
            pruneSelection()
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

    /// Presents Add Category for File › New Category. Only the main Cabinet page has the
    /// sheet; category pages opened before stay loaded and must not consume the request.
    func presentPendingCreationIfNeeded() {
        guard categoryID == nil, appNavigationModel.selectedTab == .cabinet else { return }
        guard appNavigationModel.consumePendingCreation(.category) else { return }
        showAddCategorySheet = true
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

    /// Drops `selectedCategory`/`selectedProduct` if either is no longer something this page
    /// can show — deleted directly, or (for a product) orphaned by its category being deleted
    /// — regardless of which page did the deleting (see `CabinetSelectionValidity`).
    func pruneSelection() {
        let categoryIDs = Set(categories.map(\.id))
        if let selectedCategory,
           !CabinetSelectionValidity.categoryIsValid(
               selectedCategoryID: selectedCategory.id,
               categoryIDs: categoryIDs
           ) {
            self.selectedCategory = nil
        }
        if let selectedProduct {
            // Checked before touching `.category`: a deleted model's relationships may fault
            // and crash, but its own `isDeleted` flag is safe to read.
            let isDeleted = selectedProduct.isDeleted
            let productCategoryID = isDeleted ? nil : selectedProduct.category?.id
            if !CabinetSelectionValidity.productIsValid(
                selectedProductID: selectedProduct.id,
                isDeleted: isDeleted,
                productCategoryID: productCategoryID,
                categoryIDs: categoryIDs
            ) {
                self.selectedProduct = nil
            }
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
