//
//  RecentsHeroFadeMask.swift
//  DrinkoPro
//

import SwiftUI

/// The mask for the recents hero backdrop's bottom edge: opaque at the top, clear at the bottom.
///
/// The stops follow an ease-out curve rather than a straight line, so the fade has no visible
/// starting edge where it meets the solid band.
struct RecentsHeroFadeMask: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black.opacity(0.85), location: 0.2),
                .init(color: .black.opacity(0.6), location: 0.4),
                .init(color: .black.opacity(0.32), location: 0.6),
                .init(color: .black.opacity(0.12), location: 0.8),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
