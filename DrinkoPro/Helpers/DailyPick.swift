import Foundation

/// Picks the drink of the day. The widget and Siri share it so both name the same cocktail.
enum DailyPick {
    /// The index for `date` in a pool of `count` drinks, or `nil` when the pool is empty.
    ///
    /// Uses the day's ordinal in the era, so a given day always yields the same index and
    /// consecutive days step through the pool.
    static func index(count: Int, on date: Date, calendar: Calendar = .autoupdatingCurrent) -> Int? {
        guard count > 0 else { return nil }

        let dayIndex = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return dayIndex % count
    }
}
