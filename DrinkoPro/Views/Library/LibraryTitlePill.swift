//
//  LibraryTitlePill.swift
//  DrinkoPro
//

import SwiftUI

/// A title in a Liquid Glass capsule, laid over artwork. Used by the cocktail detail header
/// and the recents deck cards. Falls back to a frosted capsule before iOS 26 / macOS 26.
struct LibraryTitlePill: View {
    let title: String
    var font: Font = .title.bold()
    /// Glass is rendered flat on screen, so it smears on a view turned in 3D. Pass `false`
    /// there to get a plain translucent capsule that turns with the view.
    var usesGlass = true

    var body: some View {
        let label = Text(title)
            .font(font)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal)
            .padding(.vertical, 8)

        Group {
            if !usesGlass {
                label.background(.white.opacity(0.7), in: .capsule)
            } else if #available(iOS 26, macOS 26, *) {
                label.glassEffect(.regular, in: .capsule)
            } else {
                label.background(.ultraThinMaterial, in: .capsule)
            }
        }
    }
}

#if DEBUG
#Preview {
    Color.mint
        .frame(height: 200)
        .overlay(alignment: .bottomLeading) {
            LibraryTitlePill(title: "Burning Bush")
                .padding()
        }
}
#endif
