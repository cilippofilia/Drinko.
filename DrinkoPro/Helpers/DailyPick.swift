import Foundation

/// Picks the drink of the day. The widget and Siri share it so both name the same cocktail.
enum DailyPick {
    /// The index for `date` in a pool of `count` drinks, or `nil` when the pool is empty.
    ///
    /// Uses the day's ordinal in the era, so a given day always yields the same index. Each day
    /// jumps about 0.618 of the pool ahead, so cocktails and shots, which sit in separate runs,
    /// are mixed while every drink still comes up once per `count` days.
    static func index(count: Int, on date: Date, calendar: Calendar = .autoupdatingCurrent) -> Int? {
        guard count > 0 else { return nil }

        let dayIndex = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return dayIndex * step(for: count) % count
    }

    /// The step nearest the golden ratio of `count` that shares no factor with it, so the days
    /// visit every index before repeating.
    static func step(for count: Int) -> Int {
        var step = max(1, Int((Double(count) * 0.618).rounded()))
        while greatestCommonDivisor(step, count) != 1 {
            step += 1
        }
        return step
    }

    private static func greatestCommonDivisor(_ first: Int, _ second: Int) -> Int {
        second == 0 ? first : greatestCommonDivisor(second, first % second)
    }
}
