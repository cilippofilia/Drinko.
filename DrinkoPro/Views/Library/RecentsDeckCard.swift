//
//  RecentsDeckCard.swift
//  DrinkoPro
//

import SwiftUI

/// One card in `RecentsDeckView`'s drum: the card's own transforms (rotation, scale, shadow,
/// fade and stacking order) for its current place around the drum, mid-swipe included.
struct RecentsDeckCard: View {
    let model: LibraryCardModel
    /// The card's place relative to the front card; see `RecentsDeckLayout.offset`.
    let offset: Int
    let count: Int
    /// The in-flight swipe as a fraction of one card, positive when dragging right.
    let dragProgress: Double
    let onOpen: () -> Void

    var body: some View {
        // The cards sit around the outside of an upright drum; dragging turns the drum.
        let steps = RecentsDeckLayout.drumSteps(forOffset: offset, count: count)
        let visibility = RecentsDeckLayout.drumVisibility(
            forSteps: steps,
            dragProgress: dragProgress,
            count: count
        )
        let angle = RecentsDeckLayout.drumAngle(forSteps: steps, dragProgress: dragProgress)
        let radians = angle * .pi / 180
        // How much the card faces the viewer: 1 at the front, 0 edge-on at the drum's side.
        let facing = cos(radians)
        // Cards further round the drum are further away, so smaller and in shadow.
        let scale = 0.7 + 0.3 * facing
        let shadowRadius: CGFloat = 6 + 10 * facing

        return Button(action: onOpen) {
            LibraryCardView(model: model, titleStyle: .blurredBand)
                .brightness(-0.25 * (1 - facing))
                .shadow(color: .black.opacity(0.12 + 0.13 * facing), radius: shadowRadius, y: shadowRadius / 2)
        }
        .buttonStyle(.libraryCard)
        .containerRelativeFrame(.horizontal) { length, _ in
            length * 0.5
        }
        .rotation3DEffect(.degrees(-angle), axis: (x: 0, y: 1, z: 0), perspective: 0.3)
        .scaleEffect(scale)
        .visualEffect { content, proxy in
            content.offset(x: proxy.size.width * 1.5 * sin(radians))
        }
        // Cards beyond the visible ones wait out of sight round the back of the drum.
        .opacity(visibility)
        // Whichever card is nearest the front, mid-swipe included, sits on top.
        .zIndex(facing)
    }
}
