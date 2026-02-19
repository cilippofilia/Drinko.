//
//  MacAddCategoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 17/06/2024.
//

import SwiftData
import SwiftUI

struct MacAddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isFocused: Bool
    @State private var categoryName = ""
    @State private var categoryDetails = ""
    @State private var categoryColor = "Dr. Blue"

    @State private var isSelected: Bool = false
    @State private var isColorsCollapsed: Bool = false
    @State private var isSuggestedCollapsed: Bool = false

    let colorColumns = [
        GridItem(.adaptive(minimum: 33))
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        "",
                        text: $categoryName
                    )
                    .accessibilityLabel("Category name")
                    .textContentType(.name)
                    .overlay(alignment: .leading) {
                        Text("Category Description")
                            .foregroundStyle(.secondary)
                            .opacity(categoryName.isEmpty ? 0.3 : 0)
                            .padding(.leading)
                    }

                    TextField(
                        "",
                        text: $categoryDetails,
                        axis: .vertical
                    )
                    .accessibilityLabel("Category details")
                    .textContentType(.name)
                    .multilineTextAlignment(.leading)
                    .overlay(alignment: .leading) {
                        Text("Category Details")
                            .foregroundStyle(.secondary)
                            .opacity(categoryDetails.isEmpty ? 0.3 : 0)
                            .padding(.leading)
                    }
                    .padding(.bottom)
                } header: {
                    Text("Info")
                }

                Section {
                    if !isColorsCollapsed {
                        LazyVGrid(columns: colorColumns) {
                            ForEach(Category.colors, id: \.self) { color in
                                colorButton(for: color)
                            }
                        }
                        .padding(.bottom)
                    }
                } header: {
                    Button {
                        withAnimation {
                            isColorsCollapsed.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.down")
                                .rotationEffect(Angle(degrees: isColorsCollapsed ? -90 : 0))
                                .animation(.snappy, value: $isColorsCollapsed.wrappedValue)
                            Text("Colors")
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(isColorsCollapsed ? "Collapsed" : "Expanded")
                }

                Section {
                    if !isSuggestedCollapsed {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Category.suggestedCategories) { category in
                                categoryRow(for: category)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } header: {
                    Button {
                        withAnimation {
                            isSuggestedCollapsed.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isSuggestedCollapsed ? -90 : 0))
                                .animation(.snappy, value: isSuggestedCollapsed)
                            Text("Suggested Categories")
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(isSuggestedCollapsed ? "Collapsed" : "Expanded")
                }

                Spacer().frame(height: 20)
            }
            .navigationTitle("Add Category")
            .padding()
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        addCategory()
                        dismiss()
                    }) {
                        Text("Save")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

// MARK: FUNCTIONS
extension MacAddCategoryView {
    func colorButton(for item: String) -> some View {
        Button {
            categoryColor = item
            isSelected.toggle()
        } label: {
            ZStack {
                Color(item)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 11, style: .continuous))

                if item == categoryColor {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.white)
                        .font(.title)
                        .symbolEffect(.bounce.down, value: isSelected)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == categoryColor ? [.isButton, .isSelected] : .isButton
        )
        .accessibilityLabel("Select color \(item)")
    }

    private func categoryRow(for category: Category) -> some View {
        Button {
            modelContext.insert(category)
            dismiss()
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .foregroundStyle(Color(category.color))
                    .frame(width: 16, height: 16)
                    .accessibilityHidden(true)
                Text(category.name)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
        .accessibilityHint("Adds this category to your cabinet.")
    }

    func addCategory() {
        let category = Category(
            name: categoryName.isEmpty ? "Category Name" : categoryName,
            detail: categoryDetails,
            color: categoryColor,
            creationDate: Date.now
        )
        modelContext.insert(category)
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return MacAddCategoryView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
