import Foundation

/// The short list of cocktails Siri registers for one-sentence phrases, which is also the
/// set of tiles the Shortcuts app shows. Any other drink is still found by name when Siri
/// asks "Which cocktail?".
nonisolated enum SuggestedCocktails {
    /// Kept small so the Shortcuts page stays readable and Siri's phrase cap isn't reached.
    static let limit = 20

    /// Well-known drinks that top up the list when there are few recents and favourites.
    static let classicIDs = [
        "negroni", "old-fashioned", "margarita", "mojito", "daiquiri",
        "espresso-martini", "manhattan", "whiskey-sour", "aperol-spritz", "gin-martini",
        "cosmopolitan", "moscow-mule", "pina-colada", "mai-tai", "french-75",
        "paloma", "sazerac", "boulevardier", "last-word", "zombie"
    ]

    /// Recents first (newest first), then favourites by name, then classics, without
    /// duplicates and only for drinks still in `library`.
    static func pick(
        recents: [String],
        favorites: Set<String>,
        from library: [Cocktail],
        limit: Int = limit
    ) -> [Cocktail] {
        let byID = Dictionary(library.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let favouritesByName = favorites
            .compactMap { byID[$0] }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .map(\.id)

        var seen = Set<String>()
        var picked: [Cocktail] = []
        for id in recents + favouritesByName + classicIDs {
            guard picked.count < limit else { break }
            guard let cocktail = byID[id], seen.insert(id).inserted else { continue }
            picked.append(cocktail)
        }
        return picked
    }

    /// Reads the saved recents and favourites; neither needs the app's observable stores.
    static func pick(from library: [Cocktail]) -> [Cocktail] {
        let recents = UserDefaults.standard.stringArray(
            forKey: RecentsStore.storageKey(for: .cocktails)
        ) ?? []
        return pick(
            recents: recents,
            favorites: FavoriteIDs.load(from: AppGroup.defaults),
            from: library
        )
    }
}
