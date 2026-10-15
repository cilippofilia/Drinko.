//
//  RecentsHeroSnapBehavior.swift
//  DrinkoPro
//

import SwiftUI

/// Snaps the recents carousel to an item, like `.viewAligned`, and reports the slot it will come
/// to rest on as soon as the finger lifts, so the band can update before the deceleration ends.
struct RecentsHeroSnapBehavior: ScrollTargetBehavior {
    /// The width of one slot.
    let itemWidth: Double
    /// Called with the slot the scroll will end on.
    let onTarget: @MainActor (Int) -> Void

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        ViewAlignedScrollTargetBehavior().updateTarget(&target, context: context)
        guard itemWidth > 0 else { return }
        // The content starts at the first slot, so slot `n`'s centre is `n + 0.5` widths in.
        let slot = Int(((target.rect.midX - itemWidth / 2) / itemWidth).rounded())
        // SwiftUI can ask for a target in the middle of a view update (a layout pass, not just a
        // lifted finger), when changing state isn't allowed, so report it afterwards.
        Task { @MainActor in
            onTarget(slot)
        }
    }
}
