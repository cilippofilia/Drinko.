//
//  LibraryCardTitleOverlay.swift
//  DrinkoPro
//

import SwiftUI

/// The title (and completion bar) a `LibraryCardView` overlays at the bottom of its artwork,
/// on top of a blurred copy of the artwork behind it (`LibraryCardBlurBand`).
struct LibraryCardTitleOverlay: View {
    let model: LibraryCardModel
    /// Draws the title text. `false` when the artwork already shows it and this card isn't
    /// forcing the label anyway — `LibraryCardView` reads the title to VoiceOver instead.
    let showsTitle: Bool
    /// The measured height of the text alone, so the blur reaches full strength right where
    /// the text starts.
    @Binding var textHeight: CGFloat
    /// The measured height of the padded title block.
    @Binding var titleHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            if showsTitle {
                Text(model.title)
                    .font(.headline)
                    .lineLimit(2)
            }

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
