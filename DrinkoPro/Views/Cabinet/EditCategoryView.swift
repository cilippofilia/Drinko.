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

    /// Lets the caller clear its selection, since `dismiss()` does nothing for a pushed view or a
    /// split view detail.
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
                ColorSwatchPicker(
                    colors: Category.colors,
                    cornerRadius: 6,
                    accessibilityHint: "Selects this color for the category.",
                    selection: $category.color
                )
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
