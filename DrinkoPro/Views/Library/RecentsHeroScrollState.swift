//
//  RecentsHeroScrollState.swift
//  DrinkoPro
//

import SwiftUI

/// The recents carousel's per-frame scroll state, kept out of `RecentsHeroView` so a swipe
/// doesn't re-evaluate the whole band.
///
/// The scroll handler writes the carousel's position here on every frame. Only
/// `RecentsHeroScrollingBackground` reads `fractionalSlot`, so a frame redraws just the
/// backdrop. The hero text reads `textStyle` instead, which changes at most a few times per
/// swipe: it is only assigned when the value actually differs, because Observation notifies
/// readers on every assignment, equal or not.
@MainActor
@Observable
final class RecentsHeroScrollState {
    /// How far, in slots, the scroll view is from the first slot. Zero until the width is known.
    private(set) var fractionalSlot = 0.0

    /// Whether the text over the band should be light or dark at the current position.
    private(set) var textStyle = RecentsHeroLayout.TextStyle.light

    // The inputs below only matter when a frame arrives, so nothing observes them.
    @ObservationIgnored private var offset = 0.0
    @ObservationIgnored private var itemWidth = 0.0
    @ObservationIgnored private var itemLuminances: [Double] = []
    @ObservationIgnored private var fallbackLuminance = 0.0
    @ObservationIgnored private var snapsFraction = false

    /// Updates what the per-frame work needs, then re-evaluates the current position.
    ///
    /// - Parameters:
    ///   - itemWidth: The slot width, which turns the scroll offset into slots.
    ///   - itemLuminances: One backdrop luminance per item.
    ///   - fallbackLuminance: The luminance to use when there are no items.
    ///   - snapsFraction: Whether the blend jumps between items (Reduce Motion).
    func configure(itemWidth: Double, itemLuminances: [Double], fallbackLuminance: Double, snapsFraction: Bool) {
        self.itemWidth = itemWidth
        self.itemLuminances = itemLuminances
        self.fallbackLuminance = fallbackLuminance
        self.snapsFraction = snapsFraction
        refresh()
    }

    /// Records the scroll view's horizontal offset, measured from the first slot being centred.
    func scroll(toOffset offset: Double) {
        self.offset = offset
        refresh()
    }

    private func refresh() {
        fractionalSlot = itemWidth > 0 ? offset / itemWidth : 0
        let luminance = RecentsHeroLayout.blendedLuminance(
            atFractionalSlot: fractionalSlot,
            itemLuminances: itemLuminances,
            snapsFraction: snapsFraction,
            fallback: fallbackLuminance
        )
        let style = RecentsHeroLayout.textStyle(forLuminance: luminance)
        if style != textStyle {
            textStyle = style
        }
    }
}
