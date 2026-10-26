import AppIntents
import Foundation
import SwiftUI

/// The shared "read the ingredients, offer the method" flow behind the recipe intents.
@MainActor
enum RecipeReader {
    static func read(
        _ cocktail: Cocktail,
        in intent: some AppIntent,
        cocktails: CocktailsViewModel
    ) async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let unit = currentUnit()
        let spoken = SpokenRecipe(
            cocktail: cocktail,
            steps: cocktails.procedureSteps(for: cocktail),
            unit: unit,
            locale: .current
        )
        let view = RecipeSnippetView(cocktail: cocktail, unit: unit)

        let prompt = String(localized: "Want the method?")
        let question = IntentDialog(stringLiteral: spoken.ingredientsSpeech + " " + prompt)

        // A "no" ends the intent; any error from the confirmation propagates unchanged.
        try await intent.requestConfirmation(actionName: .continue, dialog: question) {
            view
        }
        return .result(dialog: IntentDialog(stringLiteral: spoken.methodSpeech), view: view)
    }

    /// The unit the user chose in Settings, read the same way `@AppStorage` stores it.
    static func currentUnit() -> String {
        let stored = UserDefaults.standard.string(forKey: CocktailUnitPreference.storageKey) ?? ""
        return (CocktailUnitPreference(rawValue: stored) ?? .automatic).unit(for: .current)
    }
}
