//
//  LibraryCardButtonStyle.swift
//  DrinkoPro
//

import SwiftUI

/// A subtle scale-down press effect for library cards, rather than the dimming `.plain` applies.
/// Reduce Motion gets a slight brightness dip instead.
struct LibraryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        LibraryCardButtonLabel(configuration: configuration)
    }
}

extension ButtonStyle where Self == LibraryCardButtonStyle {
    static var libraryCard: LibraryCardButtonStyle { LibraryCardButtonStyle() }
}

/// `ButtonStyle.makeBody` can't read `accessibilityReduceMotion` directly.
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
