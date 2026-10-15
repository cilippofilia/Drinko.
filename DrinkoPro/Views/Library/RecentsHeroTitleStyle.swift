//
//  RecentsHeroTitleStyle.swift
//  DrinkoPro
//

import Foundation

/// How the recents band names its centred item.
enum RecentsHeroTitleStyle {
    /// The name in huge type, overlapping the carousel (suits cut-out stickers).
    case hero
    /// A plain caption under the carousel (suits full-bleed photos, which would hide the hero text).
    case caption

    /// How far above the band's bottom edge the backdrop starts fading into the page
    /// background. The hero row ends well above the edge, so its fade can start high behind the
    /// items' bases; a caption sits close to the edge, so its fade starts lower to keep the text
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
