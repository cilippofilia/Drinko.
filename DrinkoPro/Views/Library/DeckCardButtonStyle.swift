//
//  DeckCardButtonStyle.swift
//  DrinkoPro
//

import SwiftUI

/// A button style for the recents deck cards that shows the label as-is.
///
/// `.plain` dims the label while it's pressed, and every swipe starts with a press, so
/// the card turned see-through for the whole drag. The swipe itself is the feedback here.
struct DeckCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == DeckCardButtonStyle {
    /// Shows the label without any pressed-state dimming.
    static var deckCard: DeckCardButtonStyle { DeckCardButtonStyle() }
}
