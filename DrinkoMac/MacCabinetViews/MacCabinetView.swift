//
//  MacCabinetView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 19/01/2026.
//

import SwiftData
import SwiftUI

struct MacCabinetView: View {
    static let macCabinetTag: String? = "MacCabinet"
    @Environment(\.modelContext) private var modelContext

    @State private var showAddCategorySheet: Bool = false
    @State private var selectedCategory: Category? = nil
    @State private var selectedProduct: Item? = nil

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationStack {
            if categories.isEmpty {
                MacCabinetUnavailableView(
                    showAddCategorySheet: $showAddCategorySheet,
                    action: { showAddCategorySheet.toggle() },
                    testAction: { insertMockCategories() }
                )
            } else {
                categoriesList
                    .navigationTitle("Cabinet")
            }
        }
    }
}

extension MacCabinetView {
    var categoriesList: some View {
        List {
            ForEach(categories) { category in
                Section {
                    if let products = category.products {
                        ForEach(products) { product in
                            MacProductRowView(product: product)
                                .contentShape(.rect)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    FavoriteProductButtonView(product: product)
                                        .tint(product.isFavorite ? .red : .blue)
                                }
                        }
                    }

                    Divider()

                    Button(action: {
                        addProduct(to: category)
                    }) {
                        Label("Add Product", systemImage: "plus")
                    }
                } header: {
                    MacCategoryRowView(
                        category: category,
                        action: {
                            selectedCategory = category
                        }
                    )
                }
                .listRowSeparator(.hidden)
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            MacAddCategoryView()
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedCategory) { category in
            MacEditCategoryView(category: category)
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedProduct) { product in
            MacEditProductView(product: product)
                .presentationDetents([.medium, .large])
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showAddCategorySheet.toggle()
                }) {
                    Label("Add category", systemImage: "plus")
                }
            }
        }
        // MARK: Button used for testing purposes
        #if DEBUG
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(
                    "Clear All",
                    systemImage: "trash",
                    role: .destructive
                ) {
                    deleteAllCategoriesAndProducts()
                }
            }
        }
        #endif
    }

    func addProduct(to category: Category) {
        category.products?.append(Item(name:"Product Name"))
    }
}

// MARK: Private methods used for testing purposes
#if DEBUG
private extension MacCabinetView {
    private func insertMockCategories() {
        // Avoid inserting duplicates if categories already exist
        guard categories.isEmpty else { return }
        for mock in Category.mockCategories {
            modelContext.insert(mock)
        }
        do {
            try modelContext.save()
        } catch {
            // In previews or test mode, saving may not be critical; log if needed
            #if DEBUG
            print("Failed to save mock categories: \(error)")
            #endif
        }
    }

    private func deleteAllCategoriesAndProducts() {
        do {
            // Delete all products first
            let productDescriptor = FetchDescriptor<Item>()
            let allProducts = try modelContext.fetch(productDescriptor)
            for product in allProducts {
                modelContext.delete(product)
            }

            // Then delete all categories
            let categoryDescriptor = FetchDescriptor<Category>()
            let allCategories = try modelContext.fetch(categoryDescriptor)
            for category in allCategories {
                modelContext.delete(category)
            }

            try modelContext.save()
        } catch {
            #if DEBUG
            print("Failed to delete categories and products: \(error)")
            #endif
        }
    }
}
#endif

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()

        return MacCabinetView()
        /// comment the following line to display an emptyCabinet
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif

