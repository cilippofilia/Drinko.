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
            Button("Add a category", action: addCategory)
        })
        .frame(maxWidth: UIScreen.main.bounds.size.width * 0.83)
        .navigationTitle("Cabinet")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add category", systemImage: "plus", action: addCategory)
            }
        }
    }

    var categoriesList: some View {
        List {
            ForEach(categories) { category in
                Section(header: CategoryHeaderView(category: category)) {
                    ForEach(category.products!, id:\.self) { product in
                        ProductRowView(product: product)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                FavoriteProductButtonView(product: product)
                                    .tint(product.isFavorite ? .red : .blue)
                            }
                    }
                    .onDelete(perform: deleteProducts)

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add category", systemImage: "plus", action: addCategory)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

  var body: some View {
        NavigationStack {
            if categories.isEmpty {
                ContentUnavailableView(label: {
                    Label("Empty Cabinet", systemImage: "cabinet.fill")
                }, description: {
                    Text("To start, press 'Add a category' below or the + button at the top of the view.")
                }, actions: {
                    Button("Add a category", action: addCategory)
                })
                .frame(maxWidth: UIScreen.main.bounds.size.width * 0.83)
                .navigationTitle("Cabinet")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add category", systemImage: "plus", action: addCategory)
                    }
                }
            } else {
                categoriesList
                    .navigationTitle("Cabinet")
            }
        }
    }
}

// MARK: METHODS
extension CabinetView {
    func addCategory() {
        let category = Category(name: "Category Name",
                                detail: "",
                                color: "Dr. Blue",
                                creationDate: Date.now)
        modelContext.insert(category)
        path.append(category)
    }
    
    func addProduct(to category: Category) {
        category.products?.append(Item(name: "Product Name"))
    }
    
    func deleteProducts(at offsets: IndexSet) {
        for category in categories {
            guard category.products?.isEmpty != true else { return }
            category.products!.remove(atOffsets: offsets)
        }
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
