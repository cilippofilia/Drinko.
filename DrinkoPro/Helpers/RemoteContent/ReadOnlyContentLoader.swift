//
//  ReadOnlyContentLoader.swift
//  DrinkoPro
//

import Foundation

/// Loads valid content for the widget and the App Clip. Only the app writes the cache, so this
/// never commits or deletes anything: an invalid cached file is skipped and the next source is tried.
nonisolated struct ReadOnlyContentLoader: Sendable {
    private let cache: ContentCache?
    private let fetcher: (any ContentFetching)?
    private let language: String

    /// A nil `cache` means there is no cache (the Clip). A nil `fetcher` means offline only (the widget gallery).
    init(cache: ContentCache?, fetcher: (any ContentFetching)?, language: String) {
        self.cache = cache
        self.fetcher = fetcher
        self.language = language
    }

    /// The cached bytes if they are valid, otherwise freshly downloaded bytes that are valid, otherwise nil.
    func validData(for file: ContentFile) async -> Data? {
        if let cached = cache?.data(for: file, language: language),
           (try? ContentDecoding.validate(cached, as: file)) != nil {
            return cached
        }
        guard let fetcher,
              let result = try? await fetcher.fetch(path: file.remotePath(language: language), etag: nil),
              case .modified(let data, _) = result,
              (try? ContentDecoding.validate(data, as: file)) != nil else {
            return nil
        }
        return data
    }
}
