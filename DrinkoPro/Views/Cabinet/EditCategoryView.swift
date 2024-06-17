//
//  EditCategoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 29/01/2024.
//

import SwiftUI

struct EditCategoryView: View {
    @Bindable var category: Category
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showingDeleteConfirmation = false
    @State private var isSelected = false

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

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
                LazyVGrid(columns: colorColumns) {
                    ForEach(Category.colors, id: \.self) { color in
                        colorButton(for: color)
                    }
                }
                .padding(.vertical, 7)
            }

            Section(footer: Text("By deleting the category you will be deleting every product inside it.")) {
                Button(action: {
                    showingDeleteConfirmation.toggle()
                }) {
                    Label("Delete Category", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
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
extension EditCategoryView {
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

    func delete() {
        modelContext.delete(category)
        dismiss()
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return EditCategoryView(category: previewer.category, navigationPath: .constant(NavigationPath()))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
