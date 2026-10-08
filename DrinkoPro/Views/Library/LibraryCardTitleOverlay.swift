//
//  LibraryCardTitleOverlay.swift
//  DrinkoPro
//

import SwiftUI

/// The title (and completion bar) a `LibraryCardView` overlays at the bottom of its artwork.
struct LibraryCardTitleOverlay: View {
    let model: LibraryCardModel
    let titleStyle: LibraryCardTitleStyle
    /// The gap between the title pill and the card's edges. Only used by `.glassPill`.
    let pillInset: CGFloat
    /// The measured height of the text alone, so the blur reaches full strength right where
    /// the text starts. Only used by `.blurredBand`.
    @Binding var textHeight: CGFloat
    /// The measured height of the padded title block. Only used by `.blurredBand`.
    @Binding var titleHeight: CGFloat

    var body: some View {
        switch titleStyle {
        case .glassPill:
            VStack(alignment: .leading) {
                if model.showsCardTitle {
                    Text(model.title)
                        .font(.headline)
                        .lineLimit(2)
                        .titlePill()
                }

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(pillInset)
            // The artwork is always light, so keep the glass and text light in Dark Mode too.
            .environment(\.colorScheme, .light)
        case .blurredBand:
            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.headline)
                    .lineLimit(2)

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                textHeight = height
            }
            .padding()
            // The backdrop is always light, so keep the text dark in Dark Mode too.
            .environment(\.colorScheme, .light)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                titleHeight = height
            }
        }
    }
}
