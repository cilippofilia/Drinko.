//
//  RecentsHeroTitleStyle.swift
//  DrinkoPro
//

import Foundation

enum RecentsHeroTitleStyle {
    /// Huge type overlapping the carousel, for cut-out stickers.
    case hero
    /// A caption under the carousel, for full-bleed photos, which would hide the hero text.
    case caption

    /// A caption sits close to the band's bottom edge, so its fade starts lower to keep the text
    /// on solid backdrop.
    var fadeAboveBottom: Double {
        switch self {
        case .hero:
            56
        case .caption:
            24
        }
    }
}
