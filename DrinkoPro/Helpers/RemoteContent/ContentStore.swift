//
//  ContentStore.swift
//  DrinkoPro
//

import Foundation
import Observation
#if os(iOS)
import WidgetKit
#endif

/// Loads content at launch and refreshes it from the remote repository when the cache is stale.
@MainActor
@Observable
final class ContentStore {
    /// Where the content currently on screen came from.
    private(set) var source: ContentSource = .bundled

    @ObservationIgnored private let cache: ContentCache
    @ObservationIgnored private let refresher: ContentRefresher
    @ObservationIgnored private let language: String
    @ObservationIgnored private let bundle: Bundle
    /// The run in progress, shared by any caller that arrives while it is still going.
    @ObservationIgnored private let onContentUpdated: @MainActor () -> Void
    @ObservationIgnored private var inFlight: Task<ContentSnapshot?, Never>?

    init(
        cache: ContentCache = .standard,
        fetcher: any ContentFetching = URLSessionContentFetcher(),
        language: String = ContentLanguage.resolve(Bundle.main.preferredLocalizations),
        bundle: Bundle = .main,
        onContentUpdated: @escaping @MainActor () -> Void = ContentStore.reloadWidgets
    ) {
        self.cache = cache
        self.refresher = ContentRefresher(fetcher: fetcher, cache: cache)
        self.language = language
        self.bundle = bundle
        self.onContentUpdated = onContentUpdated
    }

    /// Asks WidgetKit to rebuild the widget so it reads the newly downloaded content.
    static func reloadWidgets() {
        #if os(iOS)
        WidgetCenter.shared.reloadTimelines(ofKind: AppGroup.widgetKind)
        #endif
    }

    /// The content to start with: the cache where valid, the bundle otherwise. Reads synchronously.
    func initialSnapshot() -> ContentSnapshot {
        let snapshot = ContentSnapshot.load(cache: cache, language: language, bundle: bundle)
        source = cachedSource()
        return snapshot
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
        if snapshot != nil {
            source = .fetched(at: .now)
            onContentUpdated()
        } else if case .fetched = source {
            // Already downloaded this launch; a later no-op run doesn't change that.
        } else {
            source = cachedSource()
        }
        return snapshot
    }

    /// `.cached` with the last successful check for this language, or `.bundled` if there is none.
    private func cachedSource() -> ContentSource {
        cache.metadata().lastSuccessfulCheck[language].map { .cached(checkedAt: $0) } ?? .bundled
    }
}
