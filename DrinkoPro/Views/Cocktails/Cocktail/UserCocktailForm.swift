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
    #if os(iOS)
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    #endif

    private let methodOptions: [String]
    private let glassOptions: [String]
    private let iceOptions: [String]
    private let unitOptions: [String]
    private let editingCocktail: Cocktail?
    private let editingProcedureSteps: [String]
    private let originalPhotoData: Data?
    private let originalStickerData: Data?

    @State private var name = ""
    @State private var method: String
    @State private var glass: String
    @State private var garnish = ""
    @State private var ice: String
    @State private var extra = ""
    @State private var ingredientDrafts: [IngredientDraft]
    @State private var procedureDrafts: [String]
    @State private var photoData: Data?
    @State private var stickerData: Data?
    @State private var tintColor: String?
    @State private var isMakingSticker = false
    @State private var alertMessage: String?

    init(
        methodOptions: [String],
        glassOptions: [String],
        iceOptions: [String],
        unitOptions: [String],
        editingCocktail: Cocktail? = nil,
        editingProcedureSteps: [String] = [],
        editingPhotoData: Data? = nil,
        editingStickerData: Data? = nil,
        editingTintColor: String? = nil
    ) {
        self.methodOptions = methodOptions
        self.glassOptions = glassOptions
        self.iceOptions = iceOptions
        self.unitOptions = unitOptions
        self.editingCocktail = editingCocktail
        self.editingProcedureSteps = editingProcedureSteps
        self.originalPhotoData = editingPhotoData
        _photoData = State(initialValue: editingPhotoData)
        self.originalStickerData = editingStickerData
        _stickerData = State(initialValue: editingStickerData)
        _tintColor = State(initialValue: editingTintColor)

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
        Form {
            UserCocktailPhotoSection(
                photoData: $photoData,
                stickerData: $stickerData,
                isMakingSticker: $isMakingSticker
            )

            UserCocktailColorSection(ingredients: parsedIngredients, tintColor: $tintColor)

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
                .labelStyle(.formAction)
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
                .labelStyle(.formAction)
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
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
                .titleOnlyBeforeGlassToolbars()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(editingCocktail == nil ? "Save" : "Update", systemImage: "checkmark") {
                    saveCocktail()
                }
                .titleOnlyBeforeGlassToolbars()
            }
        }
    }
}

// MARK: HELPER PROPERTIES
extension UserCocktailForm {
    private var saveDisabledReason: String? {
        if isMakingSticker {
            return "Wait for the sticker to finish before saving."
        }
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

// MARK: HELPER METHODS
extension UserCocktailForm {
    private static func makeInitialState(
        methodOptions: [String],
        glassOptions: [String],
        iceOptions: [String],
        unitOptions: [String],
        editingCocktail: Cocktail?,
        editingProcedureSteps: [String]
    ) -> UserCocktailFormState {
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

            return UserCocktailFormState(
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

        return UserCocktailFormState(
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

    /// What saving should do with the photo: nothing if it's untouched, so it isn't re-encoded.
    private var photoChange: UserCocktailDetails.PhotoChange {
        .between(originalPhotoData, photoData)
    }

    private var stickerChange: UserCocktailDetails.PhotoChange {
        .between(originalStickerData, stickerData)
    }

    private func saveCocktail() {
        if let saveDisabledReason {
            alertMessage = saveDisabledReason
            return
        }

        let procedureSteps = procedureDrafts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if extra.isEmpty {
            extra = "-"
        }

        let details = UserCocktailDetails(
            name: trimmedName,
            method: method,
            glass: glass,
            garnish: garnish.trimmingCharacters(in: .whitespacesAndNewlines),
            ice: ice,
            extra: extra.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: parsedIngredients,
            procedureSteps: procedureSteps,
            photoChange: photoChange,
            stickerChange: stickerChange,
            tintColor: tintColor
        )

        if let editingCocktail {
            viewModel.updateUserCocktail(editingCocktail, with: details)
        } else {
            viewModel.addUserCocktail(details)
            #if os(iOS)
            crossPromoSignal.bump()
            #endif
        }
        dismiss()
    }

    /// The drafts that are complete enough to save, as ingredients. Also what the Card Color
    /// section reads its automatic color from, so it follows the drafts as they're typed.
    private var parsedIngredients: [Ingredient] {
        ingredientDrafts.compactMap { draft -> Ingredient? in
            let trimmedIngredientName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIngredientName.isEmpty else { return nil }
            guard let quantity = parseQuantity(from: draft.quantity), quantity > 0 else { return nil }
            return Ingredient(name: trimmedIngredientName, quantity: quantity, unit: draft.unit)
        }
    }

    private func parseQuantity(from rawValue: String) -> Double? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacing(",", with: "."))
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
    UserCocktailForm(methodOptions: [], glassOptions: [], iceOptions: [], unitOptions: [])
        .environment(CocktailsViewModel())
        #if os(iOS)
        .environment(CrossPromoSignal())
        #endif
}
