//
//  ContentRefresher.swift
//  DrinkoPro
//

import Foundation

/// What a refresh did to the cache.
enum ContentRefreshOutcome: Equatable, Sendable {
    /// Every file was confirmed current. Only the check date moved.
    case unchanged
    /// At least one file was replaced or added.
    case updated
    /// Something went wrong, so the cache was left exactly as it was.
    case failed
}

/// Brings the cache up to date with the remote repository, all or nothing: nothing is written
/// unless every file was fetched (or confirmed unchanged) and validated.
struct ContentRefresher: Sendable {
    /// How long a successful check keeps the cache fresh.
    static let freshness: TimeInterval = 7 * 24 * 60 * 60

    let fetcher: any ContentFetching
    let cache: ContentCache
    let now: @Sendable () -> Date

    init(fetcher: any ContentFetching, cache: ContentCache, now: @escaping @Sendable () -> Date = Date.init) {
        self.fetcher = fetcher
        self.cache = cache
        self.now = now
    }

    /// A file downloaded and validated, waiting to be committed.
    private struct StagedFile: Sendable {
        let file: ContentFile
        let data: Data
        let etag: String?
    }

    /// Whether the last check is too old or an expected file is missing from the cache.
    func needsRefresh(language: String) -> Bool {
        guard let lastCheck = cache.metadata().lastSuccessfulCheck[language],
              now().timeIntervalSince(lastCheck) < Self.freshness else { return true }

        let topics = cachedManifest(language: language) ?? LearnTopic.bundled
        let expected = ContentFile.fixedFiles + topics.map { ContentFile.topic($0.id) }
        return expected.contains { cache.data(for: $0, language: language) == nil }
    }

    /// Fetches everything, and commits only when every file succeeded.
    func refresh(language: String) async -> ContentRefreshOutcome {
        let metadata = cache.metadata()
        do {
            // Phase 1: the manifest decides which topic files exist.
            let stagedManifest = try await stage(.topics, language: language, metadata: metadata)
            let manifestData = stagedManifest?.data ?? cache.data(for: .topics, language: language)
            guard let manifestData else { return .failed }
            let topics = try ContentDecoding.decodeTopics(from: manifestData)

            // Phase 2: everything else, concurrently. The first failure cancels the rest.
            let phaseTwo = ContentFile.fixedFiles.filter { $0 != .topics } + topics.map { ContentFile.topic($0.id) }
            var staged = stagedManifest.map { [$0] } ?? []
            try await withThrowingTaskGroup(of: StagedFile?.self) { group in
                for file in phaseTwo {
                    group.addTask { try await stage(file, language: language, metadata: metadata) }
                }
                for try await result in group {
                    if let result { staged.append(result) }
                }
            }

            var files: [ContentFile: Data] = [:]
            var etags: [String: String] = [:]
            for item in staged {
                files[item.file] = item.data
                if let etag = item.etag { etags[item.file.cacheKey(language: language)] = etag }
            }
            try cache.commit(files: files, etags: etags, language: language, checkedAt: now())
            return files.isEmpty ? .unchanged : .updated
        } catch {
            return .failed
        }
    }

    /// Fetches one file. Returns `nil` when the cached copy is confirmed current, and throws on any failure.
    private func stage(
        _ file: ContentFile, language: String, metadata: ContentCacheMetadata
    ) async throws -> StagedFile? {
        let key = file.cacheKey(language: language)
        let hasCachedCopy = cache.data(for: file, language: language) != nil
        // An ETag without a file would produce a 304 we cannot use.
        let etag = hasCachedCopy ? metadata.etags[key] : nil

        switch try await fetcher.fetch(path: file.remotePath(language: language), etag: etag) {
        case .notModified:
            guard hasCachedCopy else { throw ContentFetchError.badStatus(304) }
            return nil
        case let .modified(data, etag):
            try ContentDecoding.validate(data, as: file)
            return StagedFile(file: file, data: data, etag: etag)
        }
    }

    private func cachedManifest(language: String) -> [LearnTopic]? {
        guard let data = cache.data(for: .topics, language: language) else { return nil }
        return try? ContentDecoding.decodeTopics(from: data)
    }
}
