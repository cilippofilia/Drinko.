//
//  RecentsHeroCentreCutout.swift
//  DrinkoPro
//

import SwiftUI

/// Shows everything except a soft-edged column down the middle, one item wide, so the centred
/// item covers the hero name while its neighbours stay behind it. Built from gradients rather
/// than a blurred cut-out, so masking costs no live filter.
struct RecentsHeroCentreCutout: View {
    let width: CGFloat

    /// As a fraction of the slot's width.
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
