//
//  UserPhotoProcessor.swift
//  DrinkoPro
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Turns photos people add to their cocktails into something small enough to store and sync,
/// and decodes thumbnails for display. ImageIO only, so it works the same on iOS and macOS.
nonisolated enum UserPhotoProcessor {
    enum ProcessingError: Error {
        case unreadableImage
        case encodingFailed
    }

    /// The longest side, in pixels, of a stored photo. Plenty for a full-width header on any
    /// device while keeping CloudKit sync and memory reasonable.
    static let maxStoredPixelSize = 1600
    /// JPEG quality for stored photos.
    private static let jpegQuality = 0.8

    /// Downscales any image data to an upright JPEG no larger than `maxPixelSize`.
    /// `@concurrent` so decoding a large camera photo never blocks the main actor.
    @concurrent
    static func processedJPEG(from data: Data, maxPixelSize: Int = maxStoredPixelSize) async throws -> Data {
        guard let image = thumbnail(from: data, maxPixelSize: maxPixelSize) else {
            throw ProcessingError.unreadableImage
        }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output, UTType.jpeg.identifier as CFString, 1, nil
        ) else {
            throw ProcessingError.encodingFailed
        }
        let options = [kCGImageDestinationLossyCompressionQuality: jpegQuality] as CFDictionary
        CGImageDestinationAddImage(destination, image, options)
        guard CGImageDestinationFinalize(destination) else { throw ProcessingError.encodingFailed }
        return output as Data
    }

    /// Decodes an upright thumbnail no larger than `maxPixelSize`, or nil if `data` isn't an image.
    /// Never upscales: a smaller image comes back at its own size.
    static func thumbnail(from data: Data, maxPixelSize: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(source) > 0 else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
    }
}
