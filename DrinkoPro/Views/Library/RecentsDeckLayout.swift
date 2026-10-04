//
//  RecentsDeckLayout.swift
//  DrinkoPro
//

import Foundation

/// Index math for the recents deck, a looping carousel with the next cards on the right
/// and the previous ones on the left.
enum RecentsDeckLayout {
    /// The depth of the card at `index` when `frontIndex` is on top (0 = front).
    static func position(ofIndex index: Int, frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((index - frontIndex) % count + count) % count
    }

    /// How many steps to the side the card with `offset` fans out. The fan stays symmetric:
    /// in an even-sized deck the one card that would make it lopsided returns 0 and stays
    /// tucked behind the front card until it becomes a neighbor.
    static func fanSteps(forOffset offset: Int, count: Int) -> Int {
        let stepsPerSide = max(count - 1, 0) / 2
        return abs(offset) > stepsPerSide ? 0 : offset
    }

    /// The front index after moving to the next card (the one on the right).
    static func nextFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex + 1) % count
    }

    /// Where the card at `index` sits relative to the front card, wrapping around the deck:
    /// 0 is the front, positive values are the next cards (shown on the right) and negative
    /// values the previous ones (shown on the left). An even-sized deck puts the extra card on the right.
    static func offset(ofIndex index: Int, frontIndex: Int, count: Int) -> Int {
        let position = position(ofIndex: index, frontIndex: frontIndex, count: count)
        return position > count / 2 ? position - count : position
    }

    /// The front index after moving to the previous card (the one on the left).
    static func previousFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex - 1 + count) % count
    }
}
