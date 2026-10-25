import Foundation

/// The shared body of the add and remove favourite intents. Updates through the app's
/// `Favorites`, so the UI, the widget and iCloud sync all follow.
@MainActor
enum FavoriteUpdater {
    /// Makes `cocktail` a favourite or not, and returns what Siri says about it.
    static func set(_ cocktail: Cocktail, favorite: Bool, in favorites: Favorites) -> String {
        let name = CocktailNameMatcher.spokenName(cocktail.name)
        // Only change what differs, so repeating a request doesn't flip the heart animation.
        if favorite {
            if !favorites.contains(cocktail) { favorites.add(cocktail) }
            return String(localized: "Added \(name) to your favourites.")
        }
        if favorites.contains(cocktail) { favorites.remove(cocktail) }
        return String(localized: "Removed \(name) from your favourites.")
    }
}
