import AppIntents
import Foundation

/// "What's today's cocktail in Drinko?" Reads the same cocktail the widget shows today.
struct TodaysCocktailIntent: AppIntent {
    static let title: LocalizedStringResource = "Today's Cocktail"
    static let description = IntentDescription("Reads today's cocktail aloud, ingredients first and then the method.")
    static let openAppWhenRun = false

    @Dependency private var cocktails: CocktailsViewModel

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // The widget's All Drinks pool: cocktails then shots, without the user's own.
        let pool = cocktails.listOfCocktails + cocktails.listOfShots
        guard let index = DailyPick.index(count: pool.count, on: .now) else {
            throw RecipeIntentError.noCocktails
        }
        return try await RecipeReader.read(pool[index], in: self, cocktails: cocktails)
    }
}
