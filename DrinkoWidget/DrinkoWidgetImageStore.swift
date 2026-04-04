//
//  DrinkoWidgetImageStore.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import Foundation

enum DrinkoWidgetImageStore {
    static func imageData(for cocktail: DrinkoWidgetCocktail) -> Data? {
        guard let imageURL = cocktail.imageURL else { return nil }

        let cacheURL = cachedFileURL(for: cocktail, remoteURL: imageURL)

        if let cachedData = try? Data(contentsOf: cacheURL), !cachedData.isEmpty {
            return cachedData
        }

        guard let data = try? Data(contentsOf: imageURL), !data.isEmpty else {
            return nil
        }

        try? ensureCacheDirectoryExists(for: cacheURL)
        try? data.write(to: cacheURL, options: .atomic)
        return data
    }

    private static func cachedFileURL(for cocktail: DrinkoWidgetCocktail, remoteURL: URL) -> URL {
        let fileExtension = remoteURL.pathExtension.isEmpty ? "jpg" : remoteURL.pathExtension
        return URL.cachesDirectory
            .appending(path: "DrinkoWidget")
            .appending(path: "\(cocktail.id).\(fileExtension)")
    }

    private static func ensureCacheDirectoryExists(for fileURL: URL) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}
