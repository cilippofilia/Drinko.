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
    }
}
