//
//  RecentsHeroCentreCutout.swift
//  DrinkoPro
//

import SwiftUI

/// A mask that shows everything except a soft-edged column down the middle, one item wide.
///
/// `RecentsHeroView` masks the copy of the name drawn in front of the carousel with it, so the
/// centred item covers the name while its neighbours stay behind it. The soft edges let an item
/// move in front of the name gradually as it slides into the centre, instead of crossing a
/// hard line.
struct RecentsHeroCentreCutout: View {
    /// The width of the centre slot.
    let width: CGFloat

    /// How far the cutout's edges fade, as a fraction of the slot's width.
    private let featherFraction = 0.12

    var body: some View {
        Rectangle()
            .overlay {
                Rectangle()
                    .frame(width: width * (1 - featherFraction))
                    .blur(radius: width * featherFraction / 2)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
    }
}
