//
//  ContentStore.swift
//  DrinkoPro
//

import Foundation

/// Loads content at launch and refreshes it from the remote repository when the cache is stale.
@MainActor
final class ContentStore {
    private let cache: ContentCache
    private let refresher: ContentRefresher
    private let language: String
    private let bundle: Bundle
    /// The run in progress, shared by any caller that arrives while it is still going.
    private var inFlight: Task<ContentSnapshot?, Never>?

    init(
        cache: ContentCache = .standard,
        fetcher: any ContentFetching = URLSessionContentFetcher(),
        language: String = ContentLanguage.resolve(Bundle.main.preferredLocalizations),
        bundle: Bundle = .main
    ) {
        self.cache = cache
        self.refresher = ContentRefresher(fetcher: fetcher, cache: cache)
        self.language = language
        self.bundle = bundle
    }

    /// The content to start with: the cache where valid, the bundle otherwise. Reads synchronously.
    func initialSnapshot() -> ContentSnapshot {
        ContentSnapshot.load(cache: cache, language: language, bundle: bundle)
    }

    /// Refreshes the cache when it is stale and returns the new snapshot, or `nil` when nothing
    /// changed or the refresh failed. Concurrent callers share one run.
    func refreshIfNeeded() async -> ContentSnapshot? {
        if let inFlight {
            return await inFlight.value
        }
        let refresher = refresher
        let cache = cache
        let language = language
        let bundle = bundle
        let task = Task.detached { () -> ContentSnapshot? in
            guard refresher.needsRefresh(language: language) else { return nil }
            guard await refresher.refresh(language: language) == .updated else { return nil }
            return ContentSnapshot.load(cache: cache, language: language, bundle: bundle)
        }
        inFlight = task
        let snapshot = await task.value
        inFlight = nil
        return snapshot
    }
}
