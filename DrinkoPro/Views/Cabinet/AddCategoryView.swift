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

    func toolbarPlacement(
        isLeading: Bool? = false,
        isTrailing: Bool? = false
    ) -> ToolbarItemPlacement {
        #if os(iOS)
        if isLeading == true {
            return .topBarLeading
        } else if isTrailing == true {
            return .topBarTrailing
        } else {
            return .automatic
        }
        #elseif os(macOS)
        return .automatic
        #endif
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Info") {
                    TextField("Category name", text: $categoryName)
                        .textContentType(.name)
                        .focused($isFocused)

                    TextField(
                        "Category Details",
                        text: $categoryDetails,
                        axis: .vertical
                    )
                    .multilineTextAlignment(.leading)
                    .focused($isFocused)
                }

                Section {
                    if !isColorsCollapsed {
                        LazyVGrid(columns: colorColumns) {
                            ForEach(Category.colors, id: \.self) { color in
                                colorButton(for: color)
                            }
                        }
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
                        ForEach(Category.suggestedCategories) { category in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(Color(category.color))
                                Text(category.name)
                            }
                            .onTapGesture {
                                modelContext.insert(category)
                                dismiss()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "chevron.down")
                            .rotationEffect(Angle(degrees: isSuggestedCollapsed ? -90 : 0))
                            .animation(.snappy, value: $isSuggestedCollapsed.wrappedValue)
                        Text("Suggested Categories")
                    }
                    .onTapGesture {
                        withAnimation {
                            isSuggestedCollapsed.toggle()
                        }
                    }
                }
            }
            #if os(iOS)
            .listSectionSpacing(.compact)
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: toolbarPlacement(isTrailing: true)) {
                    Button(action: {
                        addCategory()
                        dismiss()
                    }) {
                        Text("Save")
                    }
                }
                ToolbarItem(placement: toolbarPlacement(isLeading: true)) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        isFocused = false
                    }
                }
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
                .cornerRadius(6)

            if item == categoryColor {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
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
