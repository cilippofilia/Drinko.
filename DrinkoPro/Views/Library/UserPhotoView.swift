//
//  UserPhotoView.swift
//  DrinkoPro
//

import SwiftUI

/// The user's photo of their cocktail, filling and cropping to whatever frame it's given.
/// Asks the view model for a thumbnail sized to the space on offer (read with
/// `onGeometryChange`), so a row thumbnail never decodes the full photo.
struct UserPhotoView: View {
    @Environment(CocktailsViewModel.self) private var viewModel
    @Environment(\.displayScale) private var displayScale

    let id: String
    let revision: Int

    @State private var viewSize = CGSize.zero

    /// Rounded up to a multiple of this many pixels so near-identical frames share a cached thumbnail.
    private let pixelSizeBucket = 100.0

    /// Photos can be wider or taller than the frame, and filling it scales the photo's short side
    /// up to match, so ask for 1.5x (enough to fill from a 3:2 photo). The view model clamps
    /// this to the stored size.
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
