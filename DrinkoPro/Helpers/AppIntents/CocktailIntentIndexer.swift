import AppIntents
import CoreSpotlight
import OSLog

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
    private var pendingDrinks: [Cocktail]?
    private var isUpdating = false

    private static let logger = Logger(subsystem: "me.cilia.filippo.DrinkoPro", category: "Spotlight")

    init(
        index: some CocktailSearchIndexing = CSSearchableIndex.default(),
        updateParameters: @escaping () -> Void = { DrinkoShortcuts.updateAppShortcutParameters() }
    ) {
        self.index = index
        self.updateParameters = updateParameters
    }

    /// Re-indexes every drink and refreshes Siri's parameter list. Does nothing when the
    /// ids and names match the last successful index, so repeated refreshes stay cheap.
    /// Calls made while an update is running only record the newest list; the running call
    /// picks it up, so Spotlight always ends on the latest list.
    func update(with drinks: [Cocktail]) async {
        pendingDrinks = drinks
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }

        while let next = pendingDrinks {
            pendingDrinks = nil
            await sync(next)
        }
    }

    private func sync(_ drinks: [Cocktail]) async {
        let fingerprints = drinks.map { Fingerprint(id: $0.id, name: $0.name) }
        guard fingerprints != lastFingerprints else { return }

        // Unset until both calls succeed, so a half-finished index is never treated as current.
        lastFingerprints = nil
        do {
            // Clear first so deleted user cocktails don't linger in Spotlight.
            try await index.deleteAllCocktails()
            try await index.indexCocktails(drinks.map(CocktailEntity.init))
        } catch {
            Self.logger.error("Spotlight indexing failed: \(error.localizedDescription)")
            return
        }
        lastFingerprints = fingerprints
        updateParameters()
    }
}
