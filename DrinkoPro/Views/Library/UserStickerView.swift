//
//  UserStickerView.swift
//  DrinkoPro
//

import SwiftUI

/// The user's cocktail sticker, fitted and inset on a tint wash like the bundled stickers in
/// `StickerImageView`. Asks the view model for a thumbnail sized to the space on offer, so a row
/// never decodes the full sticker.
struct UserStickerView: View {
    @Environment(\.stickerBackdropCornerRadius) private var backdropCornerRadius
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(\.displayScale) private var displayScale

    let id: String
    let revision: Int
    /// A color asset name to wash the backdrop with. `nil` leaves it plain white.
    var tint: String?
    /// Sits the sticker inset on its backdrop. Without it, the sticker fills the frame on its own.
    var showsBackdrop = true

    @State private var viewSize = CGSize.zero

    /// Rounded up to a multiple of this many pixels so near-identical frames share a cached thumbnail.
    private let pixelSizeBucket = 100.0

    private var maxPixelSize: Int? {
        let side = Double(max(viewSize.width, viewSize.height)) * displayScale
        guard side > 0 else { return nil }
        return Int((side / pixelSizeBucket).rounded(.up) * pixelSizeBucket)
    }

    var body: some View {
        Color.clear
            .overlay {
                if let maxPixelSize,
                   let image = viewModel.stickerThumbnail(for: id, revision: revision, maxPixelSize: maxPixelSize) {
                    Image(decorative: image, scale: displayScale)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(showsBackdrop ? StickerImageView.insetScale : 1)
                }
            }
            .background {
                if showsBackdrop {
                    TintWash(tint: tint)
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                viewSize = newSize
            }
            // Only the backdrop needs rounding; a bare sticker would lose its die-cut corners.
            .clipShape(.rect(cornerRadius: showsBackdrop ? backdropCornerRadius : 0, style: .continuous))
            .accessibilityHidden(true)
    }
}
