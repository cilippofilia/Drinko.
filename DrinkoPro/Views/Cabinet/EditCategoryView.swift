//
//  EditCategoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 29/01/2024.
//

import SwiftData
import SwiftUI

struct EditCategoryView: View {
    @Bindable var category: Category
    @Environment(\.modelContext) private var modelContext

    @State private var showingDeleteConfirmation = false

    /// Called after the category has been deleted from the model context, so the caller
    /// can clear its selection instead of relying on `dismiss()`, which does nothing once
    /// this view is pushed on iOS or shown as a `NavigationSplitView` detail on macOS.
    var onDelete: () -> Void = {}

    var body: some View {
        Form {
            Section("Info") {
                TextField("Category name",
                          text: $category.name)
                .textContentType(.name)

                TextField("Category Details",
                          text: $category.detail,
                          axis: .vertical)
                .multilineTextAlignment(.leading)
            }

            Section("Colors") {
                ColorSwatchPicker(colors: Category.colors, cornerRadius: 6, selection: $category.color)
                .padding(.vertical, 7)
            }

            Section(footer: Text("By deleting the category you will be deleting every product inside it.")) {
                DeleteButtonView(
                    label: "Delete Category",
                    action: {
                        showingDeleteConfirmation.toggle()
                    }
                )
                .foregroundStyle(.red)
            }
        }
        #if os(iOS)
        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Delete Category",
               isPresented: $showingDeleteConfirmation) {
            DeleteButtonView(
                label: "Delete",
                action: { delete() }
            )
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this category? You will also delete all the products it contains.")
        }
    }
}

// MARK: FUNCTIONS
extension EditCategoryView {
    func delete() {
        modelContext.delete(category)
        onDelete()
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return EditCategoryView(category: previewer.category)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
