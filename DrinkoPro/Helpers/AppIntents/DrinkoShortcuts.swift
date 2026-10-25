import AppIntents

/// The phrases Siri and Shortcuts recognise. Later tasks add their shortcuts here.
struct DrinkoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetRecipeIntent(),
            phrases: [
                "How do I make a \(\.$cocktail) in \(.applicationName)",
                "\(\.$cocktail) recipe in \(.applicationName)",
                "How to make \(\.$cocktail) with \(.applicationName)",
                "Get a recipe in \(.applicationName)"
            ],
            shortTitle: "Get Cocktail Recipe",
            systemImageName: "wineglass"
        )
        AppShortcut(
            intent: OpenCocktailIntent(),
            phrases: [
                "Show me a \(\.$target) in \(.applicationName)",
                "Open \(\.$target) in \(.applicationName)"
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
                "Add \(\.$cocktail) to my favourites in \(.applicationName)"
            ],
            shortTitle: "Add to Favourites",
            systemImageName: "heart"
        )
        AppShortcut(
            intent: RemoveFavoriteIntent(),
            phrases: [
                "Remove \(\.$cocktail) from my favourites in \(.applicationName)"
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
