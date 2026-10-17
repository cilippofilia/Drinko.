//
//  CollapsibleSectionAccessibility.swift
//  DrinkoPro
//

import SwiftUI

/// Shared so the library and the cocktail detail cards read the same way to VoiceOver.
enum CollapsibleSectionAccessibility {
    static func value(isCollapsed: Bool) -> LocalizedStringKey {
        isCollapsed ? "Collapsed" : "Expanded"
    }

    /// Two whole strings rather than one with an interpolated word, so each translates naturally.
    static func hint(isCollapsed: Bool) -> LocalizedStringKey {
        isCollapsed ? "Double tap to expand this section." : "Double tap to collapse this section."
    }
}
