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
                        MacProductView(
                            products: products,
                            color: category.color,
                            addProductAction: {
                                addProduct(to: category)
                            }
                        )
                    }
                } header: {
                    MacCategoryRowView(
                        name: category.name,
                        color: category.color,
                        buttonAction: {
                            path.append(category)
                        }
                    )
                }
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showAddCategorySheet.toggle()
                } label: {
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
