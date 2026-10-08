//
//  LibraryCardBlurBand.swift
//  DrinkoPro
//

import SwiftUI

/// The soft blur band a `.blurredBand` card shows behind its title.
///
/// Blurs the artwork that's already drawn behind it (via a material, which samples whatever
/// sits beneath it) rather than rendering a second copy of the image, so there's no duplicate
/// load or decode. Eases in from a transparent top edge so there's no visible seam, and stays
/// light even in Dark Mode so it melts into the photo's white backdrop.
struct LibraryCardBlurBand: View {
    /// How far above the text the blur starts fading in.
    let fadeHeight: CGFloat
    /// The fully blurred area: the text plus the padding below it.
    let solidHeight: CGFloat

    var body: some View {
        Rectangle()
            .fill(.thinMaterial)
            // The artwork is always light, so keep the blur light in Dark Mode too.
            .environment(\.colorScheme, .light)
            .mask(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Eased stops so the blur creeps in rather than starting at a visible line.
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black.opacity(0.1), location: 0.3),
                            .init(color: .black.opacity(0.4), location: 0.6),
                            .init(color: .black.opacity(0.8), location: 0.85),
                            .init(color: .black, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: fadeHeight)
                    Color.black
                        .frame(height: solidHeight)
                }
            }
    }
}

#if DEBUG
#Preview {
    LibraryCardBlurBand(fadeHeight: 28, solidHeight: 60)
        .frame(width: 160, height: 200)
        .background(.blue)
}
#endif
