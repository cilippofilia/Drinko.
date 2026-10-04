//
//  LibraryCardButtonStyle.swift
//  DrinkoPro
//

import SwiftUI

/// A button style for library cards (the grid and the recents deck) that shows the label as-is.
///
/// `.plain` dims the label while it's pressed, which turns a card's stacked image layers
/// see-through, and every deck swipe starts with a press.
struct LibraryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == LibraryCardButtonStyle {
    /// Shows the label without any pressed-state dimming.
    static var libraryCard: LibraryCardButtonStyle { LibraryCardButtonStyle() }
}
