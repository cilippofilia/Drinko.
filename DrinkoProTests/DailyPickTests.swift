import Foundation
import Testing
@testable import DrinkoPro

@Suite("DailyPick")
struct DailyPickTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private let start = Date(timeIntervalSince1970: 1_700_000_000)

    private func date(offsetDays: Int) -> Date {
        start.addingTimeInterval(Double(offsetDays) * 86_400)
    }

    private var pool: [WidgetCocktail] {
        (1...7).map {
            WidgetCocktail(
                id: "drink-\($0)", name: "Drink \($0)", method: "shake",
                glass: "coupe", garnish: "-", ice: "-", extra: "-", ingredients: []
            )
        }
    }

    @Test func emptyPoolHasNoPick() {
        #expect(DailyPick.index(count: 0, on: start, calendar: calendar) == nil)
    }

    @Test func matchesWidgetPick() throws {
        let pool = pool
        for day in 0..<5 {
            let when = date(offsetDays: day)
            let index = try #require(DailyPick.index(count: pool.count, on: when, calendar: calendar))
            let widgetPick = DrinkoWidgetCatalog.dailyPick(from: pool, on: when, calendar: calendar)
            #expect(widgetPick?.id == pool[index].id)
        }
    }

    @Test func consecutiveDaysStep() throws {
        let count = 7
        for day in 0..<5 {
            let todayDate = date(offsetDays: day)
            let tomorrowDate = date(offsetDays: day + 1)
            let today = try #require(DailyPick.index(count: count, on: todayDate, calendar: calendar))
            let tomorrow = try #require(DailyPick.index(count: count, on: tomorrowDate, calendar: calendar))
            #expect(tomorrow == (today + 1) % count)
        }
    }

    @Test func appPoolMatchesWidgetPool() async {
        let snapshot = ContentSnapshot.bundled()
        let loader = WidgetContentLoader.make(
            cache: nil,
            fetcher: URLSessionContentFetcher(),
            allowsNetwork: false,
            language: "en"
        )
        let drinks = await loader.drinks()
        let widgetIDs = (drinks.cocktails + drinks.shots).map(\.id)
        #expect(!widgetIDs.isEmpty)
        #expect((snapshot.cocktails + snapshot.shots).map(\.id) == widgetIDs)
    }
}
