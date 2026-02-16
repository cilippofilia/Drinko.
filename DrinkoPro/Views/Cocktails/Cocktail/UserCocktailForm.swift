//
//  AddCustomCocktailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 09/02/2026.
//

import SwiftUI

struct UserCocktailForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CocktailsViewModel.self) private var viewModel

    private let methodOptions: [String]
    private let glassOptions: [String]
    private let iceOptions: [String]
    private let unitOptions: [String]
    private let editingCocktail: Cocktail?
    private let editingProcedureSteps: [String]

    @State private var name = ""
    @State private var method: String
    @State private var glass: String
    @State private var garnish = ""
    @State private var ice: String
    @State private var extra = ""
    @State private var ingredientDrafts: [IngredientDraft]
    @State private var procedureDrafts: [String]
    @State private var alertMessage: String?

    init(
        methodOptions: [String],
        glassOptions: [String],
        iceOptions: [String],
        unitOptions: [String],
        editingCocktail: Cocktail? = nil,
        editingProcedureSteps: [String] = []
    ) {
        self.methodOptions = methodOptions
        self.glassOptions = glassOptions
        self.iceOptions = iceOptions
        self.unitOptions = unitOptions
        self.editingCocktail = editingCocktail
        self.editingProcedureSteps = editingProcedureSteps

        if let editingCocktail {
            _name = State(initialValue: editingCocktail.name)
            _method = State(initialValue: editingCocktail.method)
            _glass = State(initialValue: editingCocktail.glass)
            _garnish = State(initialValue: editingCocktail.garnish)
            _ice = State(initialValue: editingCocktail.ice)
            _extra = State(initialValue: editingCocktail.extra)

            let mappedIngredients = editingCocktail.ingredients.map {
                IngredientDraft(name: $0.name, quantity: String($0.quantity), unit: $0.unit)
            }
            _ingredientDrafts = State(
                initialValue: mappedIngredients.isEmpty
                    ? [IngredientDraft(unit: self.unitOptions.first ?? "oz.")]
                    : mappedIngredients
            )

            let trimmedProcedure = editingProcedureSteps
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            _procedureDrafts = State(initialValue: trimmedProcedure.isEmpty ? [""] : trimmedProcedure)
        } else {
            _method = State(initialValue: methodOptions.first ?? "shake & fine strain")
            _glass = State(initialValue: glassOptions.first ?? "rock")
            _ice = State(initialValue: iceOptions.first ?? "cubed")
            _ingredientDrafts = State(initialValue: [IngredientDraft(unit: self.unitOptions.first ?? "oz.")])
            _procedureDrafts = State(initialValue: [""])
        }
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

    private var saveDisabledReason: String? {
        if trimmedName.isEmpty {
            return "Add a cocktail name to enable Save."
        }

        if hasInvalidIngredientDraft {
            return "Fix ingredient fields that are missing a name or a numeric quantity."
        }

        if !hasAtLeastOneValidIngredient {
            return "Add at least one ingredient with a numeric quantity to enable Save."
        }

        return nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasAtLeastOneValidIngredient: Bool {
        ingredientDrafts.contains { draft in
            let trimmedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return false }
            guard let quantity = parseQuantity(from: draft.quantity), quantity > 0 else { return false }
            return true
        }
    }

    private var hasInvalidIngredientDraft: Bool {
        ingredientDrafts.contains { ingredientErrorMessage(for: $0) != nil }
    }

    private func parseQuantity(from rawValue: String) -> Double? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    private func ingredientErrorMessage(for draft: IngredientDraft) -> String? {
        let trimmedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQuantity = draft.quantity.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty && trimmedQuantity.isEmpty {
            return nil
        }

        if trimmedName.isEmpty {
            return "Add an ingredient name."
        }

        if trimmedQuantity.isEmpty {
            return "Add a quantity."
        }

        guard let quantity = parseQuantity(from: trimmedQuantity), quantity > 0 else {
            return "Quantity must be a number greater than 0."
        }

        return nil
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
                        Text(option.capitalizingFirstLetter())
                            .tag(option)
                    }
                }
                TextField("Garnish", text: $garnish)
                Picker("Ice", selection: $ice) {
                    ForEach(iceOptions, id: \.self) { option in
                        Text(option.capitalizingFirstLetter())
                            .tag(option)
                    }
                }
            }

            Section("Ingredients") {
                ForEach(ingredientDrafts.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Ingredient name", text: $ingredientDrafts[index].name)
                        Divider()
                        HStack {
                            TextField("Qty", text: $ingredientDrafts[index].quantity)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                            Picker("Unit", selection: $ingredientDrafts[index].unit) {
                                ForEach(unitOptions, id: \.self) { unit in
                                    Text(unit)
                                        .tag(unit)
                                }
                            }
                        }

                        if let errorMessage = ingredientErrorMessage(for: ingredientDrafts[index]) {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
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

        }
        .navigationTitle(editingCocktail == nil ? "Create Cocktail" : "Edit Cocktail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Cannot Save", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        .toolbar {
            ToolbarItem(placement: leadingToolbarPlacement) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: trailingToolbarPlacement) {
                Button(editingCocktail == nil ? "Save" : "Update") {
                    saveCocktail()
                }
            }
        }
    }

    private func saveCocktail() {
        if let saveDisabledReason {
            alertMessage = saveDisabledReason
            return
        }

        let ingredients = ingredientDrafts.compactMap { draft -> Ingredient? in
            let trimmedIngredientName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIngredientName.isEmpty else { return nil }
            guard let quantity = parseQuantity(from: draft.quantity), quantity > 0 else { return nil }
            return Ingredient(name: trimmedIngredientName, quantity: quantity, unit: draft.unit)
        }

        let procedureSteps = procedureDrafts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if extra.isEmpty {
            extra = "-"
        }

        if let editingCocktail {
            viewModel.updateUserCocktail(
                editingCocktail,
                name: trimmedName,
                method: method,
                glass: glass,
                garnish: garnish.trimmingCharacters(in: .whitespacesAndNewlines),
                ice: ice,
                extra: extra.trimmingCharacters(in: .whitespacesAndNewlines),
                ingredients: ingredients,
                procedureSteps: procedureSteps
            )
        } else {
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
        }
        dismiss()
    }
}

#Preview {
    UserCocktailForm(methodOptions: [], glassOptions: [], iceOptions: [], unitOptions: [])
        .environment(CocktailsViewModel())
}
