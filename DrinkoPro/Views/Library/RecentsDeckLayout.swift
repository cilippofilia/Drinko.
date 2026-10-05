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

    /// The most cards shown on each side of the front one; the rest wait out of sight
    /// round the back of the drum.
    static let maxVisibleStepsPerSide = 2

    /// How many cards show on each side of the front one. The drum stays symmetric, so in an
    /// even-sized deck the one card that would make it lopsided waits round the back too.
    static func visibleStepsPerSide(count: Int) -> Int {
        min(max(count - 1, 0) / 2, maxVisibleStepsPerSide)
    }

    /// How many steps round the drum the card with `offset` sits. Cards beyond the visible
    /// ones wait one step past the last visible slot on their side, so a swipe turns them
    /// into view from the edge of the drum.
    static func drumSteps(forOffset offset: Int, count: Int) -> Int {
        let limit = visibleStepsPerSide(count: count) + 1
        return min(max(offset, -limit), limit)
    }

    /// How visible a card is, from 1 (fully shown) to 0 (out of sight round the back). Cards
    /// fade over the step between the last visible slot and the waiting one, following the drag.
    static func drumVisibility(forSteps steps: Int, dragProgress: Double, count: Int) -> Double {
        let distance = abs(Double(steps) + dragProgress)
        let visibleSteps = Double(visibleStepsPerSide(count: count))
        return min(max(visibleSteps + 1 - distance, 0), 1)
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

    /// How far apart, in degrees, neighboring cards sit around the drum.
    static let drumStepAngle: Double = 36

    /// The card's angle around the drum, in degrees: 0 faces the viewer, positive values
    /// turn toward the right. `dragProgress` is the in-flight swipe, in cards (positive
    /// when dragging right), so the whole drum turns with the finger. Clamped to a quarter
    /// turn so a card never swings round the back.
    static func drumAngle(forSteps steps: Int, dragProgress: Double) -> Double {
        let angle = (Double(steps) + dragProgress) * drumStepAngle
        return min(max(angle, -90), 90)
    }

    /// The front index after moving to the previous card (the one on the left).
    static func previousFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex - 1 + count) % count
    }
}
