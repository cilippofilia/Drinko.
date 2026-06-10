import Foundation
import Testing
@testable import DrinkoPro

@Suite("DrinkoWidgetCatalog")
struct WidgetCatalogTests {
    private let cocktails: [WidgetCocktail] = [
        .init(
            id: "cocktail-1", name: "Cocktail One", method: "shake",
            glass: "coupe", garnish: "-", ice: "-", extra: "-", ingredients: []
        ),
        .init(
            id: "cocktail-2", name: "Cocktail Two", method: "stir",
            glass: "rocks", garnish: "-", ice: "cubed", extra: "-", ingredients: []
        ),
        .init(
            id: "cocktail-3", name: "Cocktail Three", method: "build",
            glass: "highball", garnish: "-", ice: "cubed", extra: "-", ingredients: []
        )
    ]

    private let shots: [WidgetCocktail] = [
        .init(
            id: "shot-1", name: "Shot One", method: "build & layer",
            glass: "shot", garnish: "-", ice: "-", extra: "-", ingredients: []
        ),
        .init(
            id: "shot-2", name: "Shot Two", method: "shake",
            glass: "shot", garnish: "-", ice: "-", extra: "-", ingredients: []
        )
    ]

    // MARK: - dailyPick

    @Test("Same date always picks the same drink")
    func dailyPickIsDeterministicForSameDate() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let pool = cocktails

        let first = DrinkoWidgetCatalog.dailyPick(from: pool, on: date)
        let second = DrinkoWidgetCatalog.dailyPick(from: pool, on: date)

        #expect(first == second)
    }

    @Test("Consecutive days advance through the pool")
    func dailyPickAdvancesOnConsecutiveDays() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date(timeIntervalSince1970: 1_700_000_000)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let pool = cocktails
        let todayPick = DrinkoWidgetCatalog.dailyPick(from: pool, on: today, calendar: calendar)
        let tomorrowPick = DrinkoWidgetCatalog.dailyPick(from: pool, on: tomorrow, calendar: calendar)

        #expect(todayPick != tomorrowPick)
    }

    @Test("Picks wrap around once the pool is exhausted")
    func dailyPickWrapsAtPoolCount() {
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        let pool = cocktails

        let dayIndex = calendar.ordinality(of: .day, in: .era, for: referenceDate) ?? 0
        let wrappedDate = calendar.date(byAdding: .day, value: pool.count, to: referenceDate)!

        let originalPick = DrinkoWidgetCatalog.dailyPick(from: pool, on: referenceDate, calendar: calendar)
        let wrappedPick = DrinkoWidgetCatalog.dailyPick(from: pool, on: wrappedDate, calendar: calendar)

        #expect(originalPick == wrappedPick)
        #expect(pool[dayIndex % pool.count] == originalPick)
    }

    @Test("An empty pool has no pick")
    func dailyPickReturnsNilForEmptyPool() {
        let pick = DrinkoWidgetCatalog.dailyPick(from: [], on: .now)

        #expect(pick == nil)
    }

    // MARK: - pool(for:)

    @Test("All Drinks combines cocktails and shots")
    func poolForAllDrinksCombinesBothLists() {
        let pool = DrinkoWidgetCatalog.pool(for: .allDrinks, cocktails: cocktails, shots: shots, favoriteIDs: [])

        #expect(pool.count == cocktails.count + shots.count)
        #expect(pool.contains(where: { $0.id == "cocktail-1" }))
        #expect(pool.contains(where: { $0.id == "shot-1" }))
    }

    @Test("Cocktails Only returns just cocktails")
    func poolForCocktailsOnlyReturnsCocktails() {
        let pool = DrinkoWidgetCatalog.pool(for: .cocktailsOnly, cocktails: cocktails, shots: shots, favoriteIDs: [])

        #expect(pool == cocktails)
    }

    @Test("Shots Only returns just shots")
    func poolForShotsOnlyReturnsShots() {
        let pool = DrinkoWidgetCatalog.pool(for: .shotsOnly, cocktails: cocktails, shots: shots, favoriteIDs: [])

        #expect(pool == shots)
    }

    @Test("Favorites Only filters cocktails and shots by favorite ID")
    func poolForFavoritesOnlyFiltersByID() {
        let favoriteIDs: Set<String> = ["cocktail-2", "shot-1"]

        let pool = DrinkoWidgetCatalog.pool(
            for: .favoritesOnly, cocktails: cocktails, shots: shots, favoriteIDs: favoriteIDs
        )

        #expect(pool.count == 2)
        #expect(pool.contains(where: { $0.id == "cocktail-2" }))
        #expect(pool.contains(where: { $0.id == "shot-1" }))
    }

    @Test("Favorites Only falls back to all drinks when there are no favorites")
    func poolForFavoritesOnlyFallsBackToAllDrinksWhenEmpty() {
        let pool = DrinkoWidgetCatalog.pool(for: .favoritesOnly, cocktails: cocktails, shots: shots, favoriteIDs: [])

        #expect(pool.count == cocktails.count + shots.count)
    }

    @Test("Favorites Only falls back to all drinks when no favorites match")
    func poolForFavoritesOnlyFallsBackWhenNoIDsMatch() {
        let favoriteIDs: Set<String> = ["unknown-id"]

        let pool = DrinkoWidgetCatalog.pool(
            for: .favoritesOnly, cocktails: cocktails, shots: shots, favoriteIDs: favoriteIDs
        )

        #expect(pool.count == cocktails.count + shots.count)
    }
}
