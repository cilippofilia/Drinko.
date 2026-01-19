//
//  AddCategoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 17/06/2024.
//

import SwiftData
import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isFocused: Bool
    @State private var categoryName = ""
    @State private var categoryDetails = ""
    @State private var categoryColor = "Dr. Blue"

    @State private var isSelected: Bool = false
    @State private var isColorsCollapsed: Bool = false
    @State private var isSuggestedCollapsed: Bool = false

    #if os(iOS)
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    #else
    let colorColumns = [
        GridItem(.adaptive(minimum: 33))
    ]
    #endif

    var leadingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .automatic
        #endif
    }

    var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    func textfieldPlaceholder(_ str: String) -> String {
        #if os(iOS)
        str
        #else
        ""
        #endif
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        textfieldPlaceholder("Category Name"),
                        text: $categoryName
                    )
                    .textContentType(.name)
                    .focused($isFocused)
                    #if os(macOS)
                    .overlay(alignment: .leading) {
                        Text("Category Description")
                            .foregroundStyle(.secondary)
                            .opacity(categoryName.isEmpty ? 0.3 : 0)
                            .padding(.leading)
                    }
                    #endif

                    TextField(
                        textfieldPlaceholder("Category Details"),
                        text: $categoryDetails,
                        axis: .vertical
                    )
                    .multilineTextAlignment(.leading)
                    .focused($isFocused)
                    #if os(macOS)
                    .overlay(alignment: .leading) {
                        Text("Category Details")
                            .opacity(categoryDetails.isEmpty ? 0.3 : 0)
                            .foregroundStyle(.secondary)
                            .padding(.leading)
                    }
                    .padding(.bottom)
                    #endif
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
                        #if os(macOS)
                        .padding(.bottom)
                        #endif
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
                        #if os(macOS)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Category.suggestedCategories) { category in
                                categoryRow(for: category)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        #else
                        ForEach(Category.suggestedCategories) { category in
                            categoryRow(for: category)
                        }
                        #endif
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

                #if os(macOS)
                Spacer().frame(height: 20)
                #endif
            }
            .navigationTitle("Add Category")
            #if os(iOS)
            .listSectionSpacing(.compact)
            .navigationBarTitleDisplayMode(.inline)
            #elseif os(macOS)
            .padding()
            #endif
            .toolbar {
                ToolbarItem(placement: trailingToolbarPlacement) {
                    Button(action: {
                        addCategory()
                        dismiss()
                    }) {
                        Text("Save")
                    }
                }
                ToolbarItem(placement: leadingToolbarPlacement) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
                #if os(IOS)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        isFocused = false
                    }
                }
                #endif
            }
        }
    }
}

// MARK: FUNCTIONS
extension AddCategoryView {
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
        #if os(macOS)
        .padding(.vertical, 2)
        #endif
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

        return AddCategoryView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
