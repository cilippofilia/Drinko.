import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Favorites")
struct FavoritesTests {
    private let cocktail = Cocktail(
        id: "negroni",
        name: "Negroni",
        method: "stir",
        glass: "rocks",
        garnish: "orange peel",
        ice: "cubed",
        extra: "-",
        ingredients: []
    )

    private let otherCocktail = Cocktail(
        id: "daiquiri",
        name: "Daiquiri",
        method: "shake",
        glass: "coupe",
        garnish: "-",
        ice: "-",
        extra: "-",
        ingredients: []
    )

    // A pair of throwaway UserDefaults suites so each test starts from a clean slate.
    private struct TestSuites {
        let suite: UserDefaults
        let legacy: UserDefaults
        let suiteName: String
        let legacyName: String

        func tearDown() {
            UserDefaults().removePersistentDomain(forName: suiteName)
            UserDefaults().removePersistentDomain(forName: legacyName)
        }
    }

    private func makeSuites() -> TestSuites {
        let suiteName = "test-suite-\(UUID().uuidString)"
        let legacyName = "test-legacy-\(UUID().uuidString)"

        let suite = UserDefaults(suiteName: suiteName)!
        let legacy = UserDefaults(suiteName: legacyName)!

        return TestSuites(suite: suite, legacy: legacy, suiteName: suiteName, legacyName: legacyName)
    }

    @Test("Legacy favorites are migrated into the App Group suite on init")
    func legacyFavoritesMigrateToSuite() throws {
        let suites = makeSuites()
        defer { suites.tearDown() }

        let legacyData = try JSONEncoder().encode(Set(["negroni"]))
        suites.legacy.set(legacyData, forKey: "Cocktails")

        let favorites = Favorites(store: suites.suite, legacy: suites.legacy)

        #expect(favorites.contains(cocktail))

        // Migration should have copied the data into the suite...
        let migratedData = suites.suite.data(forKey: "Cocktails")
        #expect(migratedData != nil)

        // ...and left the legacy copy in place as a safety net.
        let legacyCopy = suites.legacy.data(forKey: "Cocktails")
        #expect(legacyCopy != nil)
    }

    @Test("Favorites already in the suite take priority over legacy data")
    func suiteDataWinsOverLegacy() throws {
        let suites = makeSuites()
        defer { suites.tearDown() }

        let suiteData = try JSONEncoder().encode(Set(["negroni"]))
        suites.suite.set(suiteData, forKey: "Cocktails")

        let legacyData = try JSONEncoder().encode(Set(["daiquiri"]))
        suites.legacy.set(legacyData, forKey: "Cocktails")

        let favorites = Favorites(store: suites.suite, legacy: suites.legacy)

        #expect(favorites.contains(cocktail))
        #expect(!favorites.contains(otherCocktail))
    }

    @Test("Adding a cocktail persists to the injected store")
    func addingCocktailPersistsToStore() throws {
        let suites = makeSuites()
        defer { suites.tearDown() }

        let favorites = Favorites(store: suites.suite, legacy: suites.legacy)
        favorites.add(cocktail)

        #expect(favorites.contains(cocktail))

        let data = try #require(suites.suite.data(forKey: "Cocktails"))
        let decoded = try JSONDecoder().decode(Set<String>.self, from: data)
        #expect(decoded.contains("negroni"))
    }

    @Test("Removing a cocktail persists to the injected store")
    func removingCocktailPersistsToStore() throws {
        let suites = makeSuites()
        defer { suites.tearDown() }

        let favorites = Favorites(store: suites.suite, legacy: suites.legacy)
        favorites.add(cocktail)
        favorites.remove(cocktail)

        #expect(!favorites.contains(cocktail))

        let data = try #require(suites.suite.data(forKey: "Cocktails"))
        let decoded = try JSONDecoder().decode(Set<String>.self, from: data)
        #expect(!decoded.contains("negroni"))
    }

    @Test("A fresh suite with no legacy data starts empty")
    func freshSuiteStartsEmpty() {
        let suites = makeSuites()
        defer { suites.tearDown() }

        let favorites = Favorites(store: suites.suite, legacy: suites.legacy)

        #expect(!favorites.contains(cocktail))
        #expect(!favorites.contains(otherCocktail))
    }
}
