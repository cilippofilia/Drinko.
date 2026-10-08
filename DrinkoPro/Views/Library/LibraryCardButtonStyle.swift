//
//  LibraryCardButtonStyle.swift
//  DrinkoPro
//

import SwiftUI

/// A button style for library cards (the grid and the recents deck) that gives taps a subtle
/// press effect, rather than the dimming `.plain` applies.
///
/// `.plain` used to turn a card's stacked image layers see-through while pressed; now that
/// `LibraryCardView` ends with `.compositingGroup()`, cards flatten to one layer and can take
/// an ordinary scale-down press effect instead of showing no response at all. Reduce Motion
/// gets a slight brightness dip instead, since scaling is motion. The deck also uses this style
/// on cards mid-swipe; a 0.97 scale is small enough there that it doesn't fight the drag.
struct LibraryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        LibraryCardButtonLabel(configuration: configuration)
    }
}

extension ButtonStyle where Self == LibraryCardButtonStyle {
    /// Gives the label a subtle press effect instead of the `.plain` dimming.
    static var libraryCard: LibraryCardButtonStyle { LibraryCardButtonStyle() }
}

/// Wraps the label so it can read `accessibilityReduceMotion`, which `ButtonStyle.makeBody`
/// can't read directly.
private struct LibraryCardButtonLabel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let configuration: LibraryCardButtonStyle.Configuration

    var body: some View {
        configuration.label
            .animation(.snappy) { content in
                content
                    .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
                    .brightness(reduceMotion && configuration.isPressed ? -0.06 : 0)
            }
    }
}
