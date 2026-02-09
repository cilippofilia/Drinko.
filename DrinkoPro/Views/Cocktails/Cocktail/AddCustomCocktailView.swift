//
//  AddCustomCocktailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 09/02/2026.
//

import SwiftUI

struct AddCustomCocktailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CocktailsViewModel.self) private var viewModel

    private let methodOptions: [String]
    private let glassOptions: [String]
    private let iceOptions: [String]
    private let unitOptions: [String]

    @State private var name = ""
    @State private var method: String
    @State private var glass: String
    @State private var garnish = ""
    @State private var ice: String
    @State private var extra = ""
    @State private var ingredientDrafts: [IngredientDraft]
    @State private var procedureDrafts: [String]
    @State private var validationMessage: String?

    init(
        methodOptions: [String],
        glassOptions: [String],
        iceOptions: [String],
        unitOptions: [String]
    ) {
        let units = ["oz.", "ml"]

        self.methodOptions = methodOptions
        self.glassOptions = glassOptions
        self.iceOptions = iceOptions
        self.unitOptions = units
        _method = State(initialValue: methodOptions.first ?? "shake & fine strain")
        _glass = State(initialValue: glassOptions.first ?? "rock")
        _ice = State(initialValue: iceOptions.first ?? "cubed")
        _ingredientDrafts = State(initialValue: [IngredientDraft(unit: self.unitOptions.first ?? "oz.")])
        _procedureDrafts = State(initialValue: [""])
    }

    var leadingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #elseif os(macOS)
        .automatic
        #endif
    }

    var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #elseif os(macOS)
        .automatic
        #endif
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Name", text: $name)
                Picker("Method", selection: $method) {
                    ForEach(methodOptions, id: \.self) { option in
                        Text(option.capitalizingFirstLetter())
                            .tag(option)
                    }
                }
                Picker("Glass", selection: $glass) {
                    ForEach(glassOptions, id: \.self) { option in
                        Text(option.capitalizingFirstLetter()).tag(option)
                    }
                }
                TextField("Garnish", text: $garnish)
                Picker("Ice", selection: $ice) {
                    ForEach(iceOptions, id: \.self) { option in
                        Text(option.capitalizingFirstLetter()).tag(option)
                    }
                }
            }

            Section("Ingredients") {
                ForEach(ingredientDrafts.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Ingredient name", text: $ingredientDrafts[index].name)

                        HStack {
                            TextField("Qty", text: $ingredientDrafts[index].quantity)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                            Picker("Unit", selection: $ingredientDrafts[index].unit) {
                                ForEach(unitOptions, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in
                    ingredientDrafts.remove(atOffsets: offsets)
                    if ingredientDrafts.isEmpty {
                        ingredientDrafts.append(IngredientDraft(unit: unitOptions.first ?? "oz."))
                    }
                }

                Button("Add Ingredient", systemImage: "plus") {
                    ingredientDrafts.append(IngredientDraft(unit: unitOptions.first ?? "oz."))
                }
            }

            Section("Procedure") {
                ForEach(procedureDrafts.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step \(index + 1)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField(
                            "Describe this step",
                            text: $procedureDrafts[index],
                            axis: .vertical
                        )
                        .lineLimit(2...5)
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in
                    procedureDrafts.remove(atOffsets: offsets)
                    if procedureDrafts.isEmpty {
                        procedureDrafts.append("")
                    }
                }

                Button("Add Step", systemImage: "plus") {
                    procedureDrafts.append("")
                }
            }

            Section("Notes") {
                TextField("Extra notes (optional)", text: $extra, axis: .vertical)
                    .lineLimit(3...6)
            }

            if let validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Create Cocktail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: leadingToolbarPlacement) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: trailingToolbarPlacement) {
                Button("Save") {
                    saveCocktail()
                }
                .disabled(!canSave)
            }
        }
    }

    private func saveCocktail() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "A cocktail name is required."
            return
        }

        let ingredients = ingredientDrafts.compactMap { draft -> Ingredient? in
            let trimmedIngredientName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIngredientName.isEmpty else { return nil }
            guard let quantity = Double(draft.quantity.replacingOccurrences(of: ",", with: ".")), quantity > 0 else { return nil }
            return Ingredient(name: trimmedIngredientName, quantity: quantity, unit: draft.unit)
        }

        guard !ingredients.isEmpty else {
            validationMessage = "Add at least one ingredient with a valid quantity."
            return
        }

        let procedureSteps = procedureDrafts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        validationMessage = nil
        viewModel.addUserCocktail(
            name: trimmedName,
            method: method,
            glass: glass,
            garnish: garnish.trimmingCharacters(in: .whitespacesAndNewlines),
            ice: ice,
            extra: extra.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients,
            procedureSteps: procedureSteps
        )
        dismiss()
    }
}

#Preview {
    AddCustomCocktailView(methodOptions: [], glassOptions: [], iceOptions: [], unitOptions: [])
}
