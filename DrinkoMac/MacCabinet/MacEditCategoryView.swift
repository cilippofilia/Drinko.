//
//  MacEditCategoryView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 22/01/2026.
//

import SwiftData
import SwiftUI

struct MacEditCategoryView: View {
    @Bindable var category: Category
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showingDeleteConfirmation = false

    var body: some View {
        Form {
            Section {
                TextField("", text: $category.name)
                    .accessibilityLabel("Category name")
                    .textContentType(.name)
                    .overlay(alignment: .leading) {
                        Text("Category Description")
                            .foregroundStyle(.secondary)
                            .opacity(category.name.isEmpty ? 0.3 : 0)
                            .padding(.leading)
                    }

                TextField(
                    "",
                    text: $category.detail,
                    axis: .vertical
                )
                .accessibilityLabel("Category details")
                .multilineTextAlignment(.leading)
                .overlay(alignment: .leading) {
                    Text("Category Details")
                        .opacity(category.detail.isEmpty ? 0.3 : 0)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                }
                .padding(.bottom)
            } header: {
                Text("Info")
            }

            Section("Colors") {
                ColorSwatchPicker(colors: Category.colors, cornerRadius: 6, selection: $category.color)
            }

            Section {
                HStack {
                    Button("Save Changes") {
                        save()
                    }

                    DeleteButtonView(
                        label: "Delete Category",
                        action: {
                            showingDeleteConfirmation.toggle()
                        }
                    )
                    .foregroundStyle(.red)
                }
                .padding(.top)
            } footer: {
                Text("By deleting the category you will be deleting every product inside it.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Edit Category")
        .alert("Delete Category",
               isPresented: $showingDeleteConfirmation) {
            DeleteButtonView(
                label: "Delete",
                action: {
                    delete()
                }
            )
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this category? You will also delete all the products it contains.")
        }
    }
}

// MARK: FUNCTIONS
extension MacEditCategoryView {
    private func save() {
        dismiss()
    }

    func delete() {
        modelContext.delete(category)
        dismiss()
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return MacEditCategoryView(category: previewer.category)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
