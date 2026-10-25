//
//  URLSessionContentFetcher.swift
//  DrinkoPro
//

import Foundation

/// Fetches content files from the remote repository with conditional GET requests.
struct URLSessionContentFetcher: ContentFetching {
    /// The repository root that fetch paths are appended to.
    static let defaultBaseURL = URL(string: "https://raw.githubusercontent.com/cilippofilia/drinko-learn/main/")!

    /// The shorter timeout for the widget and App Clip, which have little time to run.
    static let extensionTimeout: TimeInterval = 5

    let baseURL: URL
    let session: URLSession
    let timeout: TimeInterval

    init(baseURL: URL = Self.defaultBaseURL, session: URLSession = .shared, timeout: TimeInterval = 15) {
        self.baseURL = baseURL
        self.session = session
        self.timeout = timeout
    }

    func fetch(path: String, etag: String?) async throws -> ContentFetchResult {
        var request = URLRequest(url: baseURL.appending(path: path))
        // The app's ETag logic is the only cache in play.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = timeout
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ContentFetchError.badStatus(-1)
        }
        switch http.statusCode {
        case 200:
            return .modified(data, etag: http.value(forHTTPHeaderField: "ETag"))
        case 304:
            return .notModified
        default:
            throw ContentFetchError.badStatus(http.statusCode)
        }
    }
}
