import AppIntents
import Foundation

/// "Remove the Zombie from my favourites in Drinko."
struct RemoveFavoriteIntent: AppIntent {
    static let title: LocalizedStringResource = "Remove from Favourites"
    static let description = IntentDescription("Removes a cocktail from your favourites.")
    static let openAppWhenRun = false

    @Parameter(title: "Cocktail", requestValueDialog: "Which cocktail?")
    var cocktail: CocktailEntity

    @Dependency private var cocktails: CocktailsViewModel
    @Dependency private var favorites: Favorites

    static var parameterSummary: some ParameterSummary {
        Summary("Remove \(\.$cocktail) from favourites")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let match = cocktails.listOfAllDrinks.first(where: { $0.id == cocktail.id }) else {
            throw $cocktail.needsValueError("Which cocktail?")
        }
        let dialog = FavoriteUpdater.set(match, favorite: false, in: favorites)
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
