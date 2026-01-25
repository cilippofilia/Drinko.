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

    @State private var errorTitle: String = "Something went wrong"
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false

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
        .alert(isPresented: $showError) {
            Alert(
                title: Text(errorTitle),
                message: Text(errorMessage),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    func addProduct(to category: Category) {
        category.products?.append(Item(name:"Product Name"))
    }
}

// MARK: Private methods used for testing purposes
private extension MacCabinetView {
    private func insertMockCategories() {
        // Clear existing data first
        deleteAllCategoriesAndProducts()

        // Then insert fresh mock data
        for mock in Category.mockCategories {
            modelContext.insert(mock)
        }
        do {
            try modelContext.save()
        } catch {
            showError.toggle()
            errorMessage = "Please try again.\n\nFailed to save mock categories: \(error)"
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
            showError.toggle()
            errorMessage = "Please try again.\n\nFailed to delete categories and products: \(error)"
        }
    }
}

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

