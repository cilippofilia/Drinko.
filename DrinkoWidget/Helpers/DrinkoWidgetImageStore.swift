//
//  DrinkoWidgetImageStore.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

enum DrinkoWidgetImageStore {
    /// The longest side, in pixels, a sticker is scaled down to. The originals are 1200px tall,
    /// which is more than WidgetKit will archive for a widget, so they would render blank.
    static let maxStickerPixelSize = 480

    static func stickerData(for cocktail: WidgetCocktail) -> Data? {
        guard let stickerURL = cocktail.stickerURL else { return nil }

        let cacheURL = cachedFileURL(for: cocktail)

        if let cachedData = try? Data(contentsOf: cacheURL), !cachedData.isEmpty {
            return cachedData
        }

        guard let data = try? Data(contentsOf: stickerURL),
              let downsampled = downsampledPNG(from: data) else {
            return nil
        }

        try? ensureCacheDirectoryExists(for: cacheURL)
        try? downsampled.write(to: cacheURL, options: .atomic)
        return downsampled
    }

    /// Re-encodes the image no larger than `maxStickerPixelSize`, keeping it a PNG so the
    /// sticker's die-cut transparency survives.
    static func downsampledPNG(from data: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxStickerPixelSize
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output as CFMutableData,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }

    // Stickers get their own folder so the clear cocktail pics cached by earlier versions, which
    // shared the same file names, are never shown in their place.
    private static func cachedFileURL(for cocktail: WidgetCocktail) -> URL {
        URL.cachesDirectory
            .appending(path: "DrinkoWidget")
            .appending(path: "Stickers")
            .appending(path: "\(cocktail.id).png")
    }

    private static func ensureCacheDirectoryExists(for fileURL: URL) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}
