//
//  CachedRemoteImage.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import SwiftUI

/// Displays a remote image using `RemoteImageLoader`, keeping the decoded image in `@State` so
/// re-appearing rows (or a detail pane rebuilt via `.id(selection)`) do not flash a `ProgressView`
/// or re-download an image already held by the loader's in-memory cache.
///
/// The image is requested at a pixel size derived from the space the view is given (read via
/// `onGeometryChange`, not `GeometryReader`) multiplied by the display scale, so a 45pt row
/// thumbnail never decodes a full-size source image. The view always fills that space, so give
/// it a frame.
struct CachedRemoteImage: View {
    private enum LoadState {
        case loading
        case success(CGImage)
        case failure
    }

    let url: URL?
    let contentMode: ContentMode

    @Environment(\.displayScale) private var displayScale
    @State private var loadState = LoadState.loading
    @State private var viewSize = CGSize.zero

    /// Rounds the requested pixel size up to the next multiple of this many pixels, so that
    /// views with slightly different scaled metrics (e.g. Dynamic Type row heights) still share
    /// the same cache entry.
    private let pixelSizeBucket = 50

    private var targetPixelSize: Int? {
        let maxSide = Double(max(viewSize.width, viewSize.height)) * displayScale
        guard maxSide > 0 else { return nil }

        let bucket = Double(pixelSizeBucket)
        let bucketedSide = (maxSide / bucket).rounded(.up) * bucket
        return Int(bucketedSide)
    }

    private var taskID: String? {
        guard let url, let targetPixelSize else { return nil }
        return "\(url.absoluteString)#\(targetPixelSize)"
    }

    var body: some View {
        // Measure the space on offer, not the content: while loading, the content is just a
        // small spinner, and sizing the first request to it fetched a blurry thumbnail.
        Color.clear
            .overlay { content }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                viewSize = newSize
            }
            .task(id: taskID) {
                await load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch loadState {
        case .loading:
            ProgressView()
        case .success(let cgImage):
            ImageSuccesful(image: Image(decorative: cgImage, scale: displayScale), aspectRatio: contentMode)
        case .failure:
            ImageFailedToLoad()
        }
    }

    private func load() async {
        guard let url, let targetPixelSize else { return }

        do {
            let cgImage = try await RemoteImageLoader.shared.image(for: url, maxPixelSize: targetPixelSize)
            loadState = .success(cgImage)
        } catch is CancellationError {
            // A new size or URL superseded this load; leave the current state as-is.
        } catch {
            loadState = .failure
        }
    }
}

#if DEBUG
#Preview {
    CachedRemoteImage(
        url: URL(string: "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/lemon.jpg"),
        contentMode: .fill
    )
    .frame(width: 200, height: 200)
}
#endif
