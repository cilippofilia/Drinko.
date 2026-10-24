//
//  ContentFetching.swift
//  DrinkoPro
//

import Foundation

/// The outcome of a conditional fetch.
enum ContentFetchResult: Equatable, Sendable {
    /// The server confirmed the cached copy is still current.
    case notModified
    /// The server returned a new body, with its `ETag` header verbatim if it sent one.
    case modified(Data, etag: String?)
}

/// Why a fetch failed on the server side. Transport errors are thrown as they are.
enum ContentFetchError: Error, Equatable {
    /// The status code was neither 200 nor 304, or -1 if the response was not HTTP.
    case badStatus(Int)
}

/// Downloads a content file, revalidating it against a previously stored ETag.
protocol ContentFetching: Sendable {
    /// Fetches the file at `path`, relative to the repository root.
    func fetch(path: String, etag: String?) async throws -> ContentFetchResult
}
