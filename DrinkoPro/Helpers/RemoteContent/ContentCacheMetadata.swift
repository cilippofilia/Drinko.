//
//  ContentCacheMetadata.swift
//  DrinkoPro
//

import Foundation

/// Bookkeeping stored next to the cached content files.
nonisolated struct ContentCacheMetadata: Codable, Equatable, Sendable {
    /// The last seen ETag, keyed by `ContentFile.cacheKey`.
    var etags: [String: String] = [:]
    /// When every file of a language was last confirmed up to date, keyed by language.
    var lastSuccessfulCheck: [String: Date] = [:]
}
