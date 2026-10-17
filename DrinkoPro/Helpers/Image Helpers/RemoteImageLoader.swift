//
//  RemoteImageLoader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import CoreGraphics
import Foundation
import ImageIO

/// Downloads, downsamples and caches the app's remote images, so scrolling or rebuilding a view
/// doesn't re-fetch and re-decode them. Uses its own `URLSession` and `URLCache`, keeps decoded
/// images in memory by URL and pixel size, and de-duplicates in-flight requests.
///
/// - Important: Entries are keyed by URL, so an image replaced on GitHub under the same file name
///   keeps being served until the caches drop it.
actor RemoteImageLoader {
    static let shared = RemoteImageLoader(session: RemoteImageLoader.makeDefaultSession())

    enum LoaderError: Error {
        case invalidResponse
        case decodingFailed
    }

    private struct CacheKey: Hashable {
        let url: URL
        let maxPixelSize: Int
        let filling: Bool
    }

    private let session: URLSession
    private var memoryCache: [CacheKey: CGImage] = [:]
    private var cacheOrder: [CacheKey] = []
    private var inFlightTasks: [CacheKey: Task<CGImage, Error>] = [:]

    /// The oldest entries are evicted beyond this many.
    private let maxCachedImages = 60

    /// Creates a loader backed by the given session. Tests can inject a session configured with
    /// a stub `URLProtocol`; production code should use `shared`.
    init(session: URLSession) {
        self.session = session
    }

    private static func makeDefaultSession() -> URLSession {
        let cacheDirectory = URL.cachesDirectory.appending(path: "RemoteImages")
        let urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            directory: cacheDirectory
        )

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }

    /// - Parameters:
    ///   - maxPixelSize: The frame size, in pixels, to decode the image for.
    ///   - filling: Whether the image fills (and is cropped by) that frame rather than fitting
    ///     inside it, so its shorter side must reach `maxPixelSize`.
    func image(for url: URL, maxPixelSize: Int, filling: Bool = false) async throws -> CGImage {
        let key = CacheKey(url: url, maxPixelSize: maxPixelSize, filling: filling)

        if let cached = memoryCache[key] {
            return cached
        }

        if let existingTask = inFlightTasks[key] {
            return try await existingTask.value
        }

        let session = self.session
        let task = Task<CGImage, Error> {
            try await Self.downloadAndDecode(session: session, url: url, maxPixelSize: maxPixelSize, filling: filling)
        }
        inFlightTasks[key] = task

        do {
            let image = try await task.value
            inFlightTasks[key] = nil
            store(image, for: key)
            return image
        } catch {
            inFlightTasks[key] = nil
            throw error
        }
    }

    private func store(_ image: CGImage, for key: CacheKey) {
        if memoryCache[key] == nil {
            cacheOrder.append(key)
        }
        memoryCache[key] = image

        while cacheOrder.count > maxCachedImages {
            let oldestKey = cacheOrder.removeFirst()
            memoryCache[oldestKey] = nil
        }
    }

    private static func downloadAndDecode(
        session: URLSession,
        url: URL,
        maxPixelSize: Int,
        filling: Bool
    ) async throws -> CGImage {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            // `.returnCacheDataElseLoad` ignores expiry, so a cached 404 (e.g. an image requested
            // before it was uploaded) would otherwise be served forever.
            session.configuration.urlCache?.removeCachedResponse(for: URLRequest(url: url))
            throw LoaderError.invalidResponse
        }

        return try downsample(data: data, maxPixelSize: maxPixelSize, filling: filling)
    }

    /// The longest side to decode a `sourceWidth` × `sourceHeight` image at, for a frame
    /// `targetPixelSize` pixels across.
    ///
    /// Fitting only needs the longer side to reach the target, so that's the size. Filling crops
    /// the longer side, so the shorter side must reach the target instead: the longer side is
    /// scaled up by the aspect ratio, but never past the source's own size.
    static func decodedLongestSide(
        forTargetPixelSize targetPixelSize: Int,
        sourceWidth: Int,
        sourceHeight: Int,
        filling: Bool
    ) -> Int {
        let longSide = max(sourceWidth, sourceHeight)
        let shortSide = min(sourceWidth, sourceHeight)
        guard filling, shortSide > 0 else { return targetPixelSize }

        let scaled = (Double(targetPixelSize) * Double(longSide) / Double(shortSide)).rounded(.up)
        return min(Int(scaled), longSide)
    }

    private static func downsample(data: Data, maxPixelSize: Int, filling: Bool) throws -> CGImage {
        let sourceOptions: [CFString: Any] = [kCGImageSourceShouldCache: false]
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
            throw LoaderError.decodingFailed
        }

        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let longestSide = decodedLongestSide(
            forTargetPixelSize: maxPixelSize,
            sourceWidth: properties?[kCGImagePropertyPixelWidth] as? Int ?? 0,
            sourceHeight: properties?[kCGImagePropertyPixelHeight] as? Int ?? 0,
            filling: filling
        )

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: longestSide
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            throw LoaderError.decodingFailed
        }

        return cgImage
    }
}
