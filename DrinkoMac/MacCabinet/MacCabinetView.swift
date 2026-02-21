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
    @State private var showDeleteAlert: Bool = false

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationStack {
            if categories.isEmpty {
                MacCabinetUnavailableView(
                    showAddCategorySheet: $showAddCategorySheet,
                    action: { showAddCategorySheet.toggle() }
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
                            Button {
                                selectedProduct = product
                            } label: {
                                MacProductRowView(product: product)
                            }
                            .buttonStyle(.plain)
                            .contentShape(.rect)
                            .accessibilityHint("Opens product details.")
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
                    .accessibilityHint("Adds a new product in \(category.name).")
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
                .accessibilityLabel("Add category")
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
extension MacCabinetView {
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return MacCabinetView()
        /// comment the following line to display an emptyCabinet
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
