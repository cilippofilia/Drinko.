import AppIntents
import Foundation

/// "Surprise me in Drinko." Reads a random cocktail from the whole catalog.
struct SurpriseMeIntent: AppIntent {
    static let title: LocalizedStringResource = "Surprise Me"
    static let description = IntentDescription("Picks a random cocktail and reads it aloud.")
    static let openAppWhenRun = false

    @Dependency private var cocktails: CocktailsViewModel

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let pick = cocktails.listOfAllDrinks.randomElement() else {
            throw RecipeIntentError.noCocktails
        }
        return try await RecipeReader.read(pick, in: self, cocktails: cocktails)
    }
}
