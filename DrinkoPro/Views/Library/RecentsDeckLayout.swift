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

    /// The front index after the back card returns to the top.
    static func previousFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex - 1 + count) % count
    }
}
