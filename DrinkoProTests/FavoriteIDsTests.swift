import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("FavoriteIDs")
struct FavoriteIDsTests {
    private func makeDefaults() throws -> (defaults: UserDefaults, name: String) {
        let name = "FavoriteIDsTests.\(UUID().uuidString)"
        return (try #require(UserDefaults(suiteName: name)), name)
    }

    @Test func toggleAddsThenRemoves() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        #expect(FavoriteIDs.toggle("zombie", in: defaults))
        #expect(FavoriteIDs.load(from: defaults) == ["zombie"])
        #expect(!FavoriteIDs.toggle("zombie", in: defaults))
        #expect(FavoriteIDs.load(from: defaults).isEmpty)
    }

    @Test func encodingMatchesFavorites() throws {
        let (defaults, name) = try makeDefaults()
        let (legacy, legacyName) = try makeDefaults()
        defer {
            defaults.removePersistentDomain(forName: name)
            legacy.removePersistentDomain(forName: legacyName)
        }

        FavoriteIDs.save(["negroni", "daiquiri"], to: defaults)
        let data = try #require(defaults.data(forKey: AppGroup.favoritesKey))
        #expect(try JSONDecoder().decode([String].self, from: data) == ["daiquiri", "negroni"])

        let favorites = Favorites(store: defaults, legacy: legacy)
        let negroni = Cocktail(
            id: "negroni", name: "Negroni", method: "stir", glass: "rocks", garnish: "-",
            ice: "-", extra: "-", ingredients: []
        )
        #expect(favorites.contains(negroni))

        // And the other way: what Favorites saves, FavoriteIDs reads.
        let zombie = Cocktail(
            id: "zombie", name: "Zombie", method: "shake", glass: "tiki", garnish: "-",
            ice: "-", extra: "-", ingredients: []
        )
        favorites.add(zombie)
        #expect(FavoriteIDs.load(from: defaults) == ["daiquiri", "negroni", "zombie"])
    }

    @Test func loadIgnoresGarbage() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        #expect(FavoriteIDs.load(from: defaults).isEmpty)
        defaults.set(Data("not json".utf8), forKey: AppGroup.favoritesKey)
        #expect(FavoriteIDs.load(from: defaults).isEmpty)
    }
}
