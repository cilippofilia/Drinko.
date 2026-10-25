//
//  ContentCache.swift
//  DrinkoPro
//

import Foundation

/// A durable on-disk copy of the downloaded content, laid out like the remote repository.
nonisolated struct ContentCache: Sendable {
    let root: URL

    init(root: URL) {
        self.root = root
    }

    /// The private location the cache used before it moved into the app group container.
    static var legacyRoot: URL {
        URL.applicationSupportDirectory.appending(path: "RemoteContent")
    }

    /// The cache folder inside the shared container, or the private legacy location without one.
    static func root(sharedContainer: URL?) -> URL {
        sharedContainer?.appending(path: "RemoteContent") ?? legacyRoot
    }

    /// The cache used by the app. On iOS it lives in the app group container so the widget can read it.
    static var standard: ContentCache {
        #if os(iOS)
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroup.identifier)
        return ContentCache(root: root(sharedContainer: container))
        #else
        return ContentCache(root: legacyRoot)
        #endif
    }

    private var metadataURL: URL { root.appending(path: "metadata.json") }

    private func url(for file: ContentFile, language: String) -> URL {
        root.appending(path: file.remotePath(language: language))
    }

    /// The cached bytes, or `nil` when the file hasn't been cached.
    func data(for file: ContentFile, language: String) -> Data? {
        try? Data(contentsOf: url(for: file, language: language))
    }

    /// Deletes a cached file, for example when it turns out to be undecodable.
    func remove(_ file: ContentFile, language: String) {
        try? FileManager.default.removeItem(at: url(for: file, language: language))
    }

    /// The stored metadata, or an empty value when it is missing or unreadable.
    func metadata() -> ContentCacheMetadata {
        guard let data = try? Data(contentsOf: metadataURL),
              let metadata = try? JSONDecoder().decode(ContentCacheMetadata.self, from: data) else {
            return ContentCacheMetadata()
        }
        return metadata
    }

    /// Writes every file first and the metadata last, so a crash midway keeps the old metadata.
    func commit(files: [ContentFile: Data], etags: [String: String], language: String, checkedAt: Date) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)

        var rootURL = root
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try rootURL.setResourceValues(values)

        for (file, data) in files {
            let destination = url(for: file, language: language)
            try fileManager.createDirectory(
                at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: destination, options: .atomic)
        }

        var updated = metadata()
        updated.etags.merge(etags) { _, new in new }
        updated.lastSuccessfulCheck[language] = checkedAt
        try JSONEncoder().encode(updated).write(to: metadataURL, options: .atomic)
    }
}
