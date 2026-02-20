//
//  MacUserCocktailForm.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 19/02/2026.
//

import SwiftUI

struct MacUserCocktailForm: View {
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

        let initialState = Self.makeInitialState(
            methodOptions: methodOptions,
            glassOptions: glassOptions,
            iceOptions: iceOptions,
            unitOptions: unitOptions,
            editingCocktail: editingCocktail,
            editingProcedureSteps: editingProcedureSteps
        )
        _name = State(initialValue: initialState.name)
        _method = State(initialValue: initialState.method)
        _glass = State(initialValue: initialState.glass)
        _garnish = State(initialValue: initialState.garnish)
        _ice = State(initialValue: initialState.ice)
        _extra = State(initialValue: initialState.extra)
        _ingredientDrafts = State(initialValue: initialState.ingredientDrafts)
        _procedureDrafts = State(initialValue: initialState.procedureDrafts)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Form {
                    baseInfoSection
                    ingredientsSection
                    procedureSection
                    notesSection
                }
                .padding()
            }
            .navigationTitle(editingCocktail == nil ? "Create Cocktail" : "Edit Cocktail")
            .scrollBounceBehavior(.basedOnSize)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    saveCocktail()
                }) {
                    Text(editingCocktail == nil ? "Save" : "Update")
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
        .alert("Cannot Save", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }
}

// MARK: Helper views
extension MacUserCocktailForm {
    var baseInfoSection: some View {
        Section("Basics") {
            TextField(name.isEmpty ? "" : "Name", text: $name)
                .accessibilityLabel("Cocktail name")
                .textContentType(.name)
                .overlay(alignment: .leading) {
                    Text("Cocktail name")
                        .foregroundStyle(.secondary)
                        .opacity(name.isEmpty ? 0.3 : 0)
                        .padding(.leading)
                }

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
            TextField(garnish.isEmpty ? "" : "Garnish", text: $garnish)
                .accessibilityLabel("Garnish")
                .textContentType(.name)
                .overlay(alignment: .leading) {
                    Text("Garnish")
                        .foregroundStyle(.secondary)
                        .opacity(garnish.isEmpty ? 0.3 : 0)
                        .padding(.leading)
                }

            Picker("Ice", selection: $ice) {
                ForEach(iceOptions, id: \.self) { option in
                    Text(option.capitalizingFirstLetter())
                        .tag(option)
                }
            }
            .padding(.bottom)
        }
    }

    var ingredientsSection: some View {
        Section("Ingredients") {
            ForEach(ingredientDrafts.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    TextField(
                        ingredientDrafts[index].name.isEmpty ? "" : "Ingredient name",
                        text: $ingredientDrafts[index].name
                    )
                    .accessibilityLabel("Ingredient name")
                    .textContentType(.name)
                    .overlay(alignment: .leading) {
                        Text("Ingredient name")
                            .foregroundStyle(.secondary)
                            .opacity(ingredientDrafts[index].name.isEmpty ? 0.3 : 0)
                            .padding(.leading)
                    }

                    HStack {
                        TextField(
                            ingredientDrafts[index].quantity.isEmpty ? "" : "Quantity",
                            text: $ingredientDrafts[index].quantity
                        )
                        .accessibilityLabel("Quantity")
                        .textContentType(.name)
                        .overlay(alignment: .leading) {
                            Text("Quantity")
                                .foregroundStyle(.secondary)
                                .opacity(ingredientDrafts[index].quantity.isEmpty ? 0.3 : 0)
                                .padding(.leading)
                        }

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
                .padding(.bottom, 8)
            }

            HStack {
                Button("Add Ingredient", systemImage: "plus") {
                    ingredientDrafts.append(IngredientDraft(unit: unitOptions.first ?? "oz."))
                }
                Button("Remove Ingredient", systemImage: "minus") {
                    removeLastIngredient()
                }
                .disabled(ingredientDrafts.count <= 1)
            }
            .padding(.bottom)
        }
    }

    var procedureSection: some View {
        Section("Procedure") {
            ForEach(procedureDrafts.indices, id: \.self) { index in
                TextField(
                    "Step \(index + 1)",
                    text: $procedureDrafts[index],
                    axis: .vertical
                )
                .lineLimit(2...5)
                .accessibilityLabel("Describe this step")
                .textContentType(.name)
                .padding(.bottom, 8)
            }

            HStack {
                Button("Add Step", systemImage: "plus") {
                    procedureDrafts.append("")
                }
                Button("Remove Step", systemImage: "minus") {
                    removeLastProcedureStep()
                }
                .disabled(procedureDrafts.count <= 1)
            }
            .padding(.bottom)
        }
    }

    var notesSection: some View {
        Section("Notes") {
            TextField(
                extra.isEmpty ? "" : "Extra",
                text: $extra,
                axis: .vertical
            )
            .lineLimit(3...6)
            .accessibilityLabel("Extra notes (optional)")
            .textContentType(.name)
            .overlay(alignment: .topLeading) {
                Text("Extra notes (optional)")
                    .foregroundStyle(.secondary)
                    .opacity(extra.isEmpty ? 0.3 : 0)
                    .padding(.leading)
                    .padding(.top, 4)
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Helper Properties
extension MacUserCocktailForm {
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
}

// MARK: - Helper Methods
extension MacUserCocktailForm {
    private static func makeInitialState(
        methodOptions: [String],
        glassOptions: [String],
        iceOptions: [String],
        unitOptions: [String],
        editingCocktail: Cocktail?,
        editingProcedureSteps: [String]
    ) -> (
        name: String,
        method: String,
        glass: String,
        garnish: String,
        ice: String,
        extra: String,
        ingredientDrafts: [IngredientDraft],
        procedureDrafts: [String]
    ) {
        if let editingCocktail {
            let mappedIngredients = editingCocktail.ingredients.map {
                IngredientDraft(name: $0.name, quantity: String($0.quantity), unit: $0.unit)
            }
            let ingredientDrafts = mappedIngredients.isEmpty
                ? [IngredientDraft(unit: unitOptions.first ?? "oz.")]
                : mappedIngredients
            let trimmedProcedure = editingProcedureSteps
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let procedureDrafts = trimmedProcedure.isEmpty ? [""] : trimmedProcedure

            return (
                name: editingCocktail.name,
                method: editingCocktail.method,
                glass: editingCocktail.glass,
                garnish: editingCocktail.garnish,
                ice: editingCocktail.ice,
                extra: editingCocktail.extra,
                ingredientDrafts: ingredientDrafts,
                procedureDrafts: procedureDrafts
            )
        }

        return (
            name: "",
            method: methodOptions.first ?? "shake & fine strain",
            glass: glassOptions.first ?? "rock",
            garnish: "",
            ice: iceOptions.first ?? "cubed",
            extra: "",
            ingredientDrafts: [IngredientDraft(unit: unitOptions.first ?? "oz.")],
            procedureDrafts: [""]
        )
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

    private func parseQuantity(from rawValue: String) -> Double? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacing(",", with: "."))
    }

    private func removeLastIngredient() {
        if !ingredientDrafts.isEmpty {
            ingredientDrafts.removeLast()
        }

        if ingredientDrafts.isEmpty {
            ingredientDrafts.append(IngredientDraft(unit: unitOptions.first ?? "oz."))
        }
    }

    private func removeLastProcedureStep() {
        if !procedureDrafts.isEmpty {
            procedureDrafts.removeLast()
        }

        if procedureDrafts.isEmpty {
            procedureDrafts.append("")
        }
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
}

#Preview {
    MacUserCocktailForm(methodOptions: [], glassOptions: [], iceOptions: [], unitOptions: [])
        .environment(CocktailsViewModel())
}
