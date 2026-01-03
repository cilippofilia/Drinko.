//
//  SidebarView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 23/12/2025.
//

import SwiftData
import SwiftUI

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext

    let categories: [Category]?
    let showAddCategorySheet: Binding<Bool>
    let searchText: Binding<String>
    let selectedCategory: Binding<Category?>
    let selectedProduct: Binding<Item?>

    var filteredCategories: [Category] {
        guard let categories = categories else { return [] }
        let query = searchText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedStandardContains(query) }
        }
    }

    var body: some View {
        Group {
            if let categories = categories,
               categories.isEmpty {
                emptySidebarView
            } else if filteredCategories.isEmpty {
                filteredCategoriesNotFoundView
            } else {
                categoryList
                    .overlay(alignment: .bottom) {
                        Button(action: {
                            showAddCategorySheet.wrappedValue.toggle()
                        }) {
                            Label("Add Category", systemImage: "plus")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: true , vertical: false)
                    }
            }
        }
        .sheet(isPresented: showAddCategorySheet) {
            AddCategoryView()
                .padding()
                .frame(minWidth: 400, minHeight: 300)
        }
    }

    func deleteCategory(_ category: Category) {
        if selectedCategory.wrappedValue?.id == category.id {
            selectedCategory.wrappedValue = nil
            selectedProduct.wrappedValue = nil
        }
        modelContext.delete(category)
    }
}

// MARK: Views
private extension SidebarView {
    var emptySidebarView: some View {
        ContentUnavailableView(label: {
            Label("Empty Cabinet", systemImage: "cabinet.fill")
        }, description: {
            Text("To start, press Add Category below.")
        }, actions: {
            Button(action: {
                showAddCategorySheet.wrappedValue.toggle()
            }) {
                Label("Add Category", systemImage: "plus")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: true , vertical: false)
        })
    }

    var filteredCategoriesNotFoundView: some View {
        ContentUnavailableView(label: {
            Label("OOPS!", systemImage: "cabinet.fill")
        }, description: {
            Text("No matches found.\nCheck your query or try clearing the search bar.")
        }, actions: {
            Button(action: {
                searchText.wrappedValue = ""
            }) {
                Label("Empty search bar", systemImage: "xmark.circle.fill")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: true , vertical: false)
        })
    }

    var categoryList: some View {
        List(filteredCategories, selection: selectedCategory) { category in
            NavigationLink(value: category) {
                SidebarRowView(
                    categoryName: category.name,
                    categoryDetail: category.detail,
                    products: category.products,
                    color: Color(category.color)
                )
            }
            .contextMenu {
                Button(action: {
                    selectedCategory.wrappedValue = category
                }) {
                    Label("Edit Category", systemImage: "pencil")
                }

                Divider()

                Button(action: {
                    deleteCategory(category)
                }) {
                    Label("Delete Category", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    SidebarView(
        categories: [],
        showAddCategorySheet: .constant(false),
        searchText: .constant(""),
        selectedCategory: .constant(nil),
        selectedProduct: .constant(nil)
    )
}
