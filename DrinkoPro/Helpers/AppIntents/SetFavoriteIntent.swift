import AppIntents
import Foundation

/// "Add a Zombie to my favourites in Drinko." Updates through the app's `Favorites`, so the
/// UI, the widget and iCloud sync all follow.
struct SetFavoriteIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Favourite"
    static let description = IntentDescription("Adds a cocktail to your favourites or removes it.")
    static let openAppWhenRun = false

    @Parameter(title: "Cocktail", requestValueDialog: "Which cocktail?")
    var cocktail: CocktailEntity

    @Parameter(title: "Favourite", default: true)
    var isFavorite: Bool

    @Dependency private var cocktails: CocktailsViewModel
    @Dependency private var favorites: Favorites

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$cocktail) as favourite: \(\.$isFavorite)")
    }

    init() {}

    /// For the "Remove … from my favourites" shortcut, which fixes `isFavorite` to false.
    init(isFavorite: Bool) {
        self.isFavorite = isFavorite
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let match = cocktails.listOfAllDrinks.first(where: { $0.id == cocktail.id }) else {
            throw $cocktail.needsValueError("Which cocktail?")
        }
        let name = CocktailNameMatcher.spokenName(match.name)
        // Only change what differs, so repeating a request doesn't flip the heart animation.
        if isFavorite {
            if !favorites.contains(match) { favorites.add(match) }
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "Added \(name) to your favourites.")))
        }
        if favorites.contains(match) { favorites.remove(match) }
        return .result(dialog: IntentDialog(stringLiteral: String(localized: "Removed \(name) from your favourites.")))
    }
}
