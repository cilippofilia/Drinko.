//
//  CollapsibleSectionAccessibility.swift
//  DrinkoPro
//

import SwiftUI

/// VoiceOver value and hint for any header that collapses its section, so the library and the
/// cocktail detail cards read the same way.
enum CollapsibleSectionAccessibility {
    /// The expanded/collapsed state, read out after the title.
    static func value(isCollapsed: Bool) -> LocalizedStringKey {
        isCollapsed ? "Collapsed" : "Expanded"
    }

    /// Two whole literal strings (rather than one with an interpolated word) so each
    /// reads naturally once translated.
    static func hint(isCollapsed: Bool) -> LocalizedStringKey {
        isCollapsed ? "Double tap to expand this section." : "Double tap to collapse this section."
    }
}
