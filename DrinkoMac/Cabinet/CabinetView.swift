//
//  CabinetView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 18/12/2025.
//

import SwiftData
import SwiftUI

struct CabinetView: View {
    static let cabinetTag: String? = "Cabinet"
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCategory: Category?
    @State private var selectedProduct: Item?
    @State private var showAddCategorySheet: Bool = false
    @State private var searchText: String = ""

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    var body: some View {
        NavigationSplitView {
            SidebarView(
                categories: categories,
                showAddCategorySheet: $showAddCategorySheet,
                searchText: $searchText,
                selectedCategory: $selectedCategory,
                selectedProduct: $selectedProduct
            )
        } content: {
            ContentView(
                selectedCategory: $selectedCategory,
                selectedProduct: $selectedProduct
            )
        } detail: {
            detailContent
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search categories")
    }
}

// MARK: VIEWS
extension CabinetView {
    var detailContent: some View {
        Group {
            if let selectedProduct {
                DetailsView(product: selectedProduct)
            } else {
                selectProductPlaceholder
            }
        }
    }

    var selectProductPlaceholder: some View {
        ContentUnavailableView(label: {
            Label("Select a Product", systemImage: "shippingbox")
        }, description: {
            Text("Choose a product from the list to view its details.")
        })
    }
}

#Preview {
    CabinetView()
}
