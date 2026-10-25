import AppIntents
import Foundation

/// "Add a Zombie to my favourites in Drinko."
struct AddFavoriteIntent: AppIntent {
    static let title: LocalizedStringResource = "Add to Favourites"
    static let description = IntentDescription("Adds a cocktail to your favourites.")
    static let openAppWhenRun = false

    @Parameter(title: "Cocktail", requestValueDialog: "Which cocktail?")
    var cocktail: CocktailEntity

    @Dependency private var cocktails: CocktailsViewModel
    @Dependency private var favorites: Favorites

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$cocktail) to favourites")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let match = cocktails.listOfAllDrinks.first(where: { $0.id == cocktail.id }) else {
            throw $cocktail.needsValueError("Which cocktail?")
        }
        let dialog = FavoriteUpdater.set(match, favorite: true, in: favorites)
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
