//
//  LibraryTitlePill.swift
//  DrinkoPro
//

import SwiftUI

/// A title in a Liquid Glass pill, laid over artwork. Used by the cocktail detail header
/// and the recents deck cards. Falls back to a frosted pill before iOS 26 / macOS 26.
///
/// The pill's corners are concentric with its container's, so the container must declare
/// its shape with `.containerShape(_:)` and inset the pill by `cornerInset`.
struct LibraryTitlePill: View {
    /// The gap between the pill and its container's edges.
    static let cornerInset: CGFloat = 8
    /// Keeps the pill rounded inside containers whose corners are tighter than `cornerInset`.
    private static let minimumCornerRadius: CGFloat = 8

    let title: String
    var font: Font = .title.bold()

    var body: some View {
        let label = Text(title)
            .font(font)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal)
            .padding(.vertical, 8)

        Group {
            if #available(iOS 26, macOS 26, *) {
                let shape = ConcentricRectangle(
                    corners: .concentric(minimum: .fixed(Self.minimumCornerRadius)),
                    isUniform: true
                )
                label.glassEffect(.regular, in: shape)
            } else {
                label.background(.ultraThinMaterial, in: ContainerRelativeShape())
            }
        }
        // The pill always sits on light artwork, so keep it light with dark text in Dark Mode too.
        .environment(\.colorScheme, .light)
    }
}

#if DEBUG
#Preview {
    Color.mint
        .frame(height: 200)
        .overlay(alignment: .bottomLeading) {
            LibraryTitlePill(title: "Burning Bush")
                .padding(LibraryTitlePill.cornerInset)
        }
        .containerShape(.rect(cornerRadius: libraryCardCornerRadius))
}
#endif
