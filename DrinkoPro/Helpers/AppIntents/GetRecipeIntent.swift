import AppIntents

/// "How do I make a Zombie in Drinko?" Reads the ingredients, then offers the method.
struct GetRecipeIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Cocktail Recipe"
    static let description = IntentDescription("Reads a cocktail recipe aloud, ingredients first and then the method.")
    static let openAppWhenRun = false

    @Parameter(title: "Cocktail", requestValueDialog: "Which cocktail?")
    var cocktail: CocktailEntity

    @Dependency private var cocktails: CocktailsViewModel

    static var parameterSummary: some ParameterSummary {
        Summary("Get the recipe for \(\.$cocktail)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let match = cocktails.listOfAllDrinks.first(where: { $0.id == cocktail.id }) else {
            throw $cocktail.needsValueError("Which cocktail?")
        }
        return try await RecipeReader.read(match, in: self, cocktails: cocktails)
    }
}
