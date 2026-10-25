//
//  FakeContentFetcher.swift
//  DrinkoPro
//

import Foundation
@testable import DrinkoPro

/// A scripted `ContentFetching` that records every request. Unscripted paths answer 404.
final class FakeContentFetcher: ContentFetching, @unchecked Sendable {
    private let lock = NSLock()
    private var scripted: [String: Result<ContentFetchResult, any Error>] = [:]
    private var received: [(path: String, etag: String?)] = []

    func script(_ path: String, _ result: Result<ContentFetchResult, any Error>) {
        lock.withLock { scripted[path] = result }
    }

    /// Every `(path, etag)` pair received so far.
    var requests: [(path: String, etag: String?)] {
        lock.withLock { received }
    }

    func fetch(path: String, etag: String?) async throws -> ContentFetchResult {
        let result = lock.withLock { () -> Result<ContentFetchResult, any Error>? in
            received.append((path, etag))
            return scripted[path]
        }
        guard let result else { throw ContentFetchError.badStatus(404) }
        return try result.get()
    }
}
