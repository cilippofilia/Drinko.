//
//  ContentCacheMigration.swift
//  DrinkoPro
//

import Foundation

/// Moves the content cache from private Application Support into the shared app group container.
enum ContentCacheMigration {
    /// Moves `legacy` to `shared` once. An existing shared cache wins and the legacy copy is deleted.
    /// Errors are swallowed: the app simply downloads the content again.
    static func run(from legacy: URL, to shared: URL) {
        let fileManager = FileManager.default
        guard legacy != shared, fileManager.fileExists(atPath: legacy.path(percentEncoded: false)) else { return }

        if fileManager.fileExists(atPath: shared.path(percentEncoded: false)) {
            try? fileManager.removeItem(at: legacy)
            return
        }

        try? fileManager.createDirectory(
            at: shared.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? fileManager.moveItem(at: legacy, to: shared)
    }

    /// Migrates the standard cache. A no-op on macOS, where both locations are the same.
    static func runIfNeeded() {
        run(from: ContentCache.legacyRoot, to: ContentCache.standard.root)
    }
}
