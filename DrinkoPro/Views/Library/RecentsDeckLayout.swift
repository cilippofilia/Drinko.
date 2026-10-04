//
//  RecentsDeckLayout.swift
//  DrinkoPro
//

import Foundation

/// Index math for the recents deck, where cards cycle front-to-back.
enum RecentsDeckLayout {
    /// The depth of the card at `index` when `frontIndex` is on top (0 = front).
    static func position(ofIndex index: Int, frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((index - frontIndex) % count + count) % count
    }

    /// The front index after the top card moves to the back.
    static func nextFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex + 1) % count
    }

    /// How far to the side the card at `position` peeks out from behind the front card:
    /// positive is right, negative is left, 0 is the front card. Odd positions peek right
    /// and even ones left, each pair one step further out than the pair in front of it.
    static func peekSteps(forPosition position: Int) -> Int {
        guard position > 0 else { return 0 }
        let steps = (position + 1) / 2
        return position.isMultiple(of: 2) ? -steps : steps
    }

    /// The front index after the back card returns to the top.
    static func previousFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex - 1 + count) % count
    }
}
