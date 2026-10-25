import AppIntents

/// "Show me a Zombie in Drinko", and what a Spotlight result runs when tapped.
struct OpenCocktailIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Cocktail"
    static let description = IntentDescription("Opens a cocktail in Drinko.")

    @Parameter(title: "Cocktail", requestValueDialog: "Which cocktail?")
    var target: CocktailEntity

    @Dependency private var navigation: AppNavigationModel

    @MainActor
    func perform() async throws -> some IntentResult {
        navigation.selectedTab = .cocktails
        navigation.pendingCocktailID = target.id
        return .result()
    }
}
