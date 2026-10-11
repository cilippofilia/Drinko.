//
//  RecentsHeroWallpaperCache.swift
//  DrinkoPro
//

import CoreImage
import Foundation

/// Makes and remembers the blurred photos behind the recents band.
///
/// The photo is fetched at a tiny size and blurred once with Core Image, off the main actor,
/// so the band never runs a live Gaussian blur over a full-height view while it scrolls. The
/// results are cached per URL, and concurrent requests for the same URL share one task.
actor RecentsHeroWallpaperCache {
    static let shared = RecentsHeroWallpaperCache()

    /// The longest side, in pixels, the photo is decoded at. The blur throws the detail away
    /// anyway, and a small image is cheap to blur and to keep.
    private let sourcePixelSize = 48
    /// The blur radius, in pixels of the small image. It dissolves the photo into a wash of
    /// its colors.
    private let blurRadius = 3.0
    /// Evicts the oldest wallpaper beyond this many.
    private let maxCachedWallpapers = 20

    private let context = CIContext()
    private var cache: [URL: CGImage] = [:]
    private var cacheOrder: [URL] = []
    private var inFlight: [URL: Task<CGImage?, Never>] = [:]

    /// The blurred wallpaper for the photo at `url`, or `nil` if it couldn't be loaded.
    func wallpaper(for url: URL) async -> CGImage? {
        if let cached = cache[url] { return cached }
        if let task = inFlight[url] { return await task.value }

        let task = Task<CGImage?, Never> { [self] in
            guard let photo = try? await RemoteImageLoader.shared.image(for: url, maxPixelSize: sourcePixelSize) else {
                return nil
            }
            return blurred(photo)
        }
        inFlight[url] = task
        let result = await task.value
        inFlight[url] = nil
        if let result { store(result, for: url) }
        return result
    }

    private func store(_ image: CGImage, for url: URL) {
        if cache[url] == nil { cacheOrder.append(url) }
        cache[url] = image
        while cacheOrder.count > maxCachedWallpapers {
            cache[cacheOrder.removeFirst()] = nil
        }
    }

    /// Blurs `image`, clamping its edges first so the blur doesn't fade to transparent at the
    /// borders, then crops back to the original size.
    private func blurred(_ image: CGImage) -> CGImage? {
        let input = CIImage(cgImage: image)
        let output = input
            .clampedToExtent()
            .applyingGaussianBlur(sigma: blurRadius)
            .cropped(to: input.extent)
        return context.createCGImage(output, from: output.extent)
    }
}
