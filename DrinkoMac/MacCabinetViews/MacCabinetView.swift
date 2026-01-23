//
//  MacCabinetView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 19/01/2026.
//

import SwiftData
import SwiftUI

struct MacCabinetView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var showAddCategorySheet: Bool = false

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]


    var body: some View {
        NavigationStack(path: $path) {
            if categories.isEmpty {
                MacCabinetUnavailableView(showAddCategorySheet: $showAddCategorySheet) {
                    showAddCategorySheet.toggle()
                }
            } else {
                categoriesList
                    .navigationTitle("Cabinet")
            }
        }
        .navigationDestination(for: Category.self) { category in
            EditCategoryView(category: category, navigationPath: $path)
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
                            ProductRowView(product: product)
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
                    MacCategoryRowView(category: category)
                }
                .listRowSeparator(.hidden)
            }
        }
        .navigationDestination(for: Category.self) { category in
            MacEditCategoryView(category: category, navigationPath: $path)
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
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView()
                .presentationDetents([.medium, .large])
        }
    }

    func addProduct(to category: Category) {
        category.products?.append(Item(name: "Product Name"))
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
