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
    @State private var isSelected = false

    let colorColumns = [
        GridItem(.adaptive(minimum: 33))
    ]

    var body: some View {
        Form {
            Section {
                TextField("", text: $category.name)
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
                LazyVGrid(columns: colorColumns) {
                    ForEach(Category.colors, id: \.self) { color in
                        colorButton(for: color)
                    }
                }
            }

            Section {
                HStack {
                    Button("Save Changes") {
                        save()
                    }

                    Button(
                        "Delete Category",
                        systemImage: "trash",
                        role: .destructive
                    ) {
                        showingDeleteConfirmation.toggle()
                    }
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
            Button("Delete", role: .destructive) { delete() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this category? You will also delete all the products it contains.")
        }
    }
}

// MARK: FUNCTIONS
extension MacEditCategoryView {
    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if item == category.color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.title)
                    .symbolEffect(.bounce.down, value: isSelected)
            }
        }
        .onTapGesture {
            category.color = item
            isSelected.toggle()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == category.color ? [.isButton, .isSelected] : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }

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
        let previewer = try Previewer()

        return MacEditCategoryView(category: previewer.category)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
