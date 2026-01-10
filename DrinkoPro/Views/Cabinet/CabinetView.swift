//
//  CabinetView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftData
import SwiftUI

struct CabinetView: View {
    static let cabinetTag: String? = "Cabinet"
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var showAddCategorySheet: Bool = false

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationStack {
            if categories.isEmpty {
                unavailableView
            } else {
                categoriesList
                    .navigationTitle("Cabinet")
            }
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
        .frame(width: screenWidth * 0.9)
        #if os(iOS)
        .navigationTitle("Cabinet")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showAddCategorySheet.toggle()
                }) {
                    Label("Add category", systemImage: "plus")
                }
            }
        }
        #endif
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView()
        }
    }

    var categoriesList: some View {
        List {
            ForEach(categories) { category in
                Section(header: CategoryHeaderView(category: category)) {
                    ForEach(category.products!) { product in
                        ProductRowView(product: product)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                FavoriteProductButtonView(product: product)
                                    .tint(product.isFavorite ? .red : .blue)
                            }
                    }

                    Button(action: {
                        addProduct(to: category)
                    }) {
                        Label("Add Product", systemImage: "plus")
                    }
                }
            }
        }
        .navigationDestination(for: Category.self) { category in
            EditCategoryView(category: category, navigationPath: $path)
        }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showAddCategorySheet.toggle()
                }) {
                    Label("Add category", systemImage: "plus")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        #endif
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView()
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: METHODS
extension CabinetView {
    func addProduct(to category: Category) {
        category.products?.append(Item(name: "Product Name"))
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return CabinetView()
        /// comment the following line to display an emptyCabinet
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
