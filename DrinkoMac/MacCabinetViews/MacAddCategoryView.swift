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
                    .multilineTextAlignment(.leading)
                    .overlay(alignment: .leading) {
                        Text("Category Details")
                            .opacity(categoryDetails.isEmpty ? 0.3 : 0)
                            .foregroundStyle(.secondary)
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
                    HStack {
                        Image(systemName: "chevron.down")
                            .rotationEffect(Angle(degrees: isColorsCollapsed ? -90 : 0))
                            .animation(.snappy, value: $isColorsCollapsed.wrappedValue)
                        Text("Colors")
                    }
                    .onTapGesture {
                        withAnimation {
                            isColorsCollapsed.toggle()
                        }
                    }
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
                    HStack {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isSuggestedCollapsed ? -90 : 0))
                            .animation(.snappy, value: isSuggestedCollapsed)
                        Text("Suggested Categories")
                    }
                    .onTapGesture {
                        withAnimation {
                            isSuggestedCollapsed.toggle()
                        }
                    }
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
        .onTapGesture {
            categoryColor = item
            isSelected.toggle()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == categoryColor ? [.isButton, .isSelected] : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }

    private func categoryRow(for category: Category) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .foregroundStyle(Color(category.color))
                .frame(width: 16, height: 16)
            Text(category.name)
        }
        .padding(.vertical, 2)
        .onTapGesture {
            modelContext.insert(category)
            dismiss()
        }
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
        let previewer = try Previewer()

        return MacAddCategoryView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
