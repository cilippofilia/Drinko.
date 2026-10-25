import AppIntents
import CoreSpotlight

/// Keeps Spotlight and Siri's cocktail list in step with the drinks the app shows.
@MainActor
final class CocktailIntentIndexer {
    private struct Fingerprint: Equatable {
        let id: String
        let name: String
    }

    private let index: any CocktailSearchIndexing
    private let updateParameters: () -> Void
    private var lastFingerprints: [Fingerprint]?

    init(
        index: some CocktailSearchIndexing = CSSearchableIndex.default(),
        updateParameters: @escaping () -> Void = { DrinkoShortcuts.updateAppShortcutParameters() }
    ) {
        self.index = index
        self.updateParameters = updateParameters
    }

    /// Re-indexes every drink and refreshes Siri's parameter list. Does nothing when the
    /// ids and names match the previous call, so repeated refreshes stay cheap.
    func update(with drinks: [Cocktail]) async {
        let fingerprints = drinks.map { Fingerprint(id: $0.id, name: $0.name) }
        guard fingerprints != lastFingerprints else { return }

        do {
            // Clear first so deleted user cocktails don't linger in Spotlight.
            try await index.deleteAllCocktails()
            try await index.indexCocktails(drinks.map(CocktailEntity.init))
        } catch {
            // Leave the fingerprint unset so the next change retries.
            return
        }
        lastFingerprints = fingerprints
        updateParameters()
    }
}
