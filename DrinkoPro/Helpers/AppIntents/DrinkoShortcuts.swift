import AppIntents

/// The phrases Siri and Shortcuts recognise. Each phrase that names a cocktail is registered
/// once per suggested cocktail, and Siri caps the total, so keep those phrases few.
struct DrinkoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetRecipeIntent(),
            phrases: [
                "How do I make a \(\.$cocktail) in \(.applicationName)",
                "\(\.$cocktail) recipe in \(.applicationName)",
                "Get a recipe in \(.applicationName)"
            ],
            shortTitle: "Get Cocktail Recipe",
            systemImageName: "wineglass"
        )
        AppShortcut(
            intent: OpenCocktailIntent(),
            phrases: [
                "Open \(\.$target) in \(.applicationName)",
                "Open a cocktail in \(.applicationName)"
            ],
            shortTitle: "Open Cocktail",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: TodaysCocktailIntent(),
            phrases: [
                "What's today's cocktail in \(.applicationName)",
                "Cocktail of the day in \(.applicationName)"
            ],
            shortTitle: "Today's Cocktail",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: SurpriseMeIntent(),
            phrases: [
                "Surprise me in \(.applicationName)",
                "Pick a random cocktail in \(.applicationName)"
            ],
            shortTitle: "Surprise Me",
            systemImageName: "dice"
        )
        AppShortcut(
            intent: AddFavoriteIntent(),
            phrases: [
                "Add \(\.$cocktail) to my favourites in \(.applicationName)",
                "Add to my favourites in \(.applicationName)"
            ],
            shortTitle: "Add to Favourites",
            systemImageName: "heart"
        )
        AppShortcut(
            intent: RemoveFavoriteIntent(),
            phrases: [
                "Remove \(\.$cocktail) from my favourites in \(.applicationName)",
                "Remove from my favourites in \(.applicationName)"
            ],
            shortTitle: "Remove from Favourites",
            systemImageName: "heart.slash"
        )
        AppShortcut(
            intent: AddBottleIntent(),
            phrases: [
                "Add to my cabinet in \(.applicationName)",
                "Restock my cabinet in \(.applicationName)"
            ],
            shortTitle: "Restock Cabinet",
            systemImageName: "plus.circle"
        )
    }
}
