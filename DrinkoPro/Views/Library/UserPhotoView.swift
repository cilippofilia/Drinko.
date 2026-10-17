//
//  UserPhotoView.swift
//  DrinkoPro
//

import SwiftUI

/// Fills and crops to its frame, asking for a thumbnail sized to the space on offer so a row
/// never decodes the full photo.
struct UserPhotoView: View {
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(\.displayScale) private var displayScale

    let id: String
    let revision: Int

    @State private var viewSize = CGSize.zero

    /// Rounded up to a multiple of this many pixels so near-identical frames share a cached thumbnail.
    private let pixelSizeBucket = 100.0

    /// Filling scales the photo's short side up to the frame, so ask for 1.5x (enough for a 3:2
    /// photo). The view model clamps this to the stored size.
    private let fillAllowance = 1.5

    private var maxPixelSize: Int? {
        let side = Double(max(viewSize.width, viewSize.height)) * displayScale * fillAllowance
        guard side > 0 else { return nil }
        return Int((side / pixelSizeBucket).rounded(.up) * pixelSizeBucket)
    }

    var body: some View {
        Color.clear
            .overlay {
                if let maxPixelSize,
                   let image = viewModel.photoThumbnail(for: id, revision: revision, maxPixelSize: maxPixelSize) {
                    Image(decorative: image, scale: displayScale)
                        .resizable()
                        .scaledToFill()
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                viewSize = newSize
            }
            .clipped()
            .accessibilityHidden(true)
    }
}
