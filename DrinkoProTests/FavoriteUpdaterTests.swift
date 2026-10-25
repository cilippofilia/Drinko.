import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("FavoriteUpdater")
struct FavoriteUpdaterTests {
    private let negroni = Cocktail(
        id: "negroni", name: "Negroni", method: "stir", glass: "rocks",
        garnish: "-", ice: "-", extra: "-", ingredients: []
    )

    private let zombie = Cocktail(
        id: "zombie", name: "Zombie (1934)", method: "shake", glass: "tiki mug",
        garnish: "-", ice: "-", extra: "-", ingredients: []
    )

    /// A throwaway store and legacy suite, removed when `body` returns.
    private func withFavorites(_ body: (Favorites, UserDefaults) throws -> Void) throws {
        let storeName = "test-updater-\(UUID().uuidString)"
        let legacyName = "test-updater-legacy-\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: storeName))
        let legacy = try #require(UserDefaults(suiteName: legacyName))
        defer {
            UserDefaults().removePersistentDomain(forName: storeName)
            UserDefaults().removePersistentDomain(forName: legacyName)
        }
        try body(Favorites(store: store, legacy: legacy), store)
    }

    @Test
    func addingMakesItAFavorite() throws {
        try withFavorites { favorites, _ in
            let dialog = FavoriteUpdater.set(zombie, favorite: true, in: favorites)
            #expect(favorites.contains(zombie))
            #expect(dialog == "Added Zombie to your favourites.")
        }
    }

    @Test
    func removingMakesItNotAFavorite() throws {
        try withFavorites { favorites, _ in
            favorites.add(zombie)
            let dialog = FavoriteUpdater.set(zombie, favorite: false, in: favorites)
            #expect(!favorites.contains(zombie))
            #expect(dialog == "Removed Zombie from your favourites.")
        }
    }

    @Test
    func repeatingAnAddKeepsItAFavorite() throws {
        try withFavorites { favorites, _ in
            _ = FavoriteUpdater.set(zombie, favorite: true, in: favorites)
            let dialog = FavoriteUpdater.set(zombie, favorite: true, in: favorites)
            #expect(favorites.contains(zombie))
            #expect(dialog == "Added Zombie to your favourites.")
        }
    }

    @Test
    func keepsAFavoriteTheWidgetSavedMeanwhile() throws {
        try withFavorites { favorites, store in
            // The widget writes straight to the store; the app's copy hasn't seen it yet.
            FavoriteIDs.save(["negroni"], to: store)
            _ = FavoriteUpdater.set(zombie, favorite: true, in: favorites)
            #expect(favorites.contains(negroni))
            #expect(favorites.contains(zombie))
            #expect(FavoriteIDs.load(from: store) == ["negroni", "zombie"])
        }
    }
}
