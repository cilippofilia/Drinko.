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
///
/// It is built from plain shapes and two linear gradients rather than a blurred cut-out, so
/// masking costs no live filter. Each edge is a gradient `featherFraction` of the slot wide,
/// centred on the slot's edge.
struct RecentsHeroCentreCutout: View {
    /// The width of the centre slot.
    let width: CGFloat

    /// How far the cutout's edges fade, as a fraction of the slot's width.
    private let featherFraction = 0.12

    var body: some View {
        HStack(spacing: 0) {
            Color.black
            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: width * featherFraction)
            Color.clear
                .frame(width: width * (1 - 2 * featherFraction))
            LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                .frame(width: width * featherFraction)
            Color.black
        }
    }
}
