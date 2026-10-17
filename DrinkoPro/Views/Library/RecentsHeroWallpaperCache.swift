//
//  RecentsHeroWallpaperCache.swift
//  DrinkoPro
//

import CoreImage
import Foundation

/// Blurs the recents band's photos once, at a tiny size, so the band never runs a live blur
/// while it scrolls.
actor RecentsHeroWallpaperCache {
    static let shared = RecentsHeroWallpaperCache()

    /// The blur throws the detail away anyway, and a small image is cheap to blur and keep.
    private let sourcePixelSize = 48
    /// In pixels of the small image.
    private let blurRadius = 3.0
    /// Evicts the oldest wallpaper beyond this many.
    private let maxCachedWallpapers = 20

    private let context = CIContext()
    private var cache: [URL: CGImage] = [:]
    private var cacheOrder: [URL] = []
    private var inFlight: [URL: Task<CGImage?, Never>] = [:]

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

    /// Clamps the edges first so the blur doesn't fade to transparent at the borders.
    private func blurred(_ image: CGImage) -> CGImage? {
        let input = CIImage(cgImage: image)
        let output = input
            .clampedToExtent()
            .applyingGaussianBlur(sigma: blurRadius)
            .cropped(to: input.extent)
        return context.createCGImage(output, from: output.extent)
    }
}
