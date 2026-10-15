//
//  RemoteImageLoader.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import CoreGraphics
import Foundation
import ImageIO

/// Downloads, decodes and caches small remote thumbnails (currently the Learn feature's book and
/// lesson images) so that scrolling a list, or rebuilding a detail pane, does not repeatedly
/// re-fetch and re-decode the same full-size JPEG.
///
/// The loader owns a dedicated `URLSession` with its own `URLCache` (so on-disk HTTP caching does
/// not compete with, or get evicted by, other requests the app makes) and keeps a small in-memory
/// dictionary of already-decoded, already-downsampled `CGImage`s keyed by URL and target pixel
/// size. In-flight requests for the same key are de-duplicated so that, for example, a fast
/// scroll that re-appears the same row multiple times only triggers one download.
///
/// - Important: Trade-off — because entries are cached by URL (and requested pixel size) alone,
///   if an image is replaced on GitHub under the *same* filename, the previously cached copy will
///   keep being served until the in-memory cache is evicted (e.g. under memory pressure or after
///   the app relaunches) or the on-disk `URLCache` entry expires/is purged. For this app's static
///   learning images that trade-off is acceptable in exchange for not re-fetching on every scroll.
actor RemoteImageLoader {
    /// Shared loader backed by a dedicated `URLSession`/`URLCache` pair.
    static let shared = RemoteImageLoader(session: RemoteImageLoader.makeDefaultSession())

    /// Errors thrown while fetching or decoding a remote image.
    enum LoaderError: Error {
        /// The server did not respond with a successful (2xx) HTTP status.
        case invalidResponse
        /// The downloaded data could not be decoded as an image.
        case decodingFailed
    }

    private struct CacheKey: Hashable {
        let url: URL
        let maxPixelSize: Int
    }

    private let session: URLSession
    private var memoryCache: [CacheKey: CGImage] = [:]
    private var cacheOrder: [CacheKey] = []
    private var inFlightTasks: [CacheKey: Task<CGImage, Error>] = [:]

    /// A simple count-based eviction limit for the in-memory cache; oldest entries are evicted
    /// first once this many distinct (url, pixel size) combinations are cached.
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

    /// Returns a downsampled, decoded image for `url`, serving it from the in-memory cache when
    /// available and de-duplicating concurrent requests for the same URL/size.
    ///
    /// - Parameters:
    ///   - url: The remote image's URL.
    ///   - maxPixelSize: The maximum width/height, in pixels, to decode the image at. Passing the
    ///     view's actual rendered size (in pixels) avoids decoding a full-size image for a small
    ///     thumbnail.
    /// - Returns: The decoded, downsampled `CGImage`.
    func image(for url: URL, maxPixelSize: Int) async throws -> CGImage {
        let key = CacheKey(url: url, maxPixelSize: maxPixelSize)

        if let cached = memoryCache[key] {
            return cached
        }

        if let existingTask = inFlightTasks[key] {
            return try await existingTask.value
        }

        let session = self.session
        let task = Task<CGImage, Error> {
            try await Self.downloadAndDecode(session: session, url: url, maxPixelSize: maxPixelSize)
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

    private static func downloadAndDecode(session: URLSession, url: URL, maxPixelSize: Int) async throws -> CGImage {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            // `.returnCacheDataElseLoad` ignores expiry, so a cached 404 (e.g. an image requested
            // before it was uploaded) would otherwise be served forever.
            session.configuration.urlCache?.removeCachedResponse(for: URLRequest(url: url))
            throw LoaderError.invalidResponse
        }

        return try downsample(data: data, maxPixelSize: maxPixelSize)
    }

    private static func downsample(data: Data, maxPixelSize: Int) throws -> CGImage {
        let sourceOptions: [CFString: Any] = [kCGImageSourceShouldCache: false]
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
            throw LoaderError.decodingFailed
        }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            throw LoaderError.decodingFailed
        }

        return cgImage
    }
}
