import AppIntents
import Foundation
import SwiftData

/// "Add to my cabinet in Drinko." Adds bottles to the Cabinet one after another, guessing each
/// bottle's category and asking only when unsure.
struct AddBottleIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Bottle to Cabinet"
    static let description = IntentDescription("Adds bottles to your Cabinet.")
    static let openAppWhenRun = false

    @Parameter(title: "Bottle", requestValueDialog: "Which bottle?")
    var bottle: String

    @Parameter(title: "Category")
    var category: CabinetCategoryEntity?

    @Dependency private var modelContainer: ModelContainer

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$bottle) to \(\.$category)")
    }

    private static var noCategoryDialog: IntentDialog {
        IntentDialog(stringLiteral: String(localized: "Create a category in Drinko first."))
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = modelContainer.mainContext
        let allCategories = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        guard !allCategories.isEmpty else {
            return .result(dialog: Self.noCategoryDialog)
        }
        let candidates = allCategories
            .sorted { $0.creationDate < $1.creationDate }
            .map { CategoryCandidate(id: $0.id, name: $0.name, color: $0.color) }

        var current = bottle
        while true {
            let target = try await chooseCategory(for: current, among: candidates)
            guard let model = allCategories.first(where: { $0.id == target.id }) else {
                return .result(dialog: Self.noCategoryDialog)
            }
            let existing = (model.products ?? []).map(\.name)

            let summary: String
            if CabinetCategoryGuesser.isDuplicate(current, in: existing) {
                summary = String(localized: "\(current) is already in \(target.name).")
            } else {
                let name = current.trimmingCharacters(in: .whitespacesAndNewlines)
                model.products?.append(Item(name: name))
                try context.save()
                summary = String(localized: "Added \(name) to \(target.name).")
            }

            // A "no" ends the intent through the thrown error, as in `RecipeReader`. Each bottle
            // is already saved, so nothing is lost.
            let question = summary + " " + String(localized: "Anything else?")
            try await requestConfirmation(actionName: .continue, dialog: IntentDialog(stringLiteral: question))
            current = try await $bottle.requestValue(IntentDialog(stringLiteral: String(localized: "Which bottle?")))
        }
    }

    /// The category chosen in Shortcuts, else a keyword guess, else the model's guess, else a question.
    @MainActor
    private func chooseCategory(
        for name: String,
        among candidates: [CategoryCandidate]
    ) async throws -> CategoryCandidate {
        if let chosen = category, let match = candidates.first(where: { $0.id == chosen.id }) { return match }
        if let guess = CabinetCategoryGuesser.guess(bottle: name, among: candidates) { return guess }
        if let guess = await ModelCategoryGuesser.guess(bottle: name, among: candidates) { return guess }

        let options = candidates.map { CabinetCategoryEntity(id: $0.id, name: $0.name) }
        let picked = try await $category.requestDisambiguation(
            among: options,
            dialog: IntentDialog(stringLiteral: String(localized: "Which category?"))
        )
        return candidates.first { $0.id == picked.id } ?? candidates[0]
    }
}
