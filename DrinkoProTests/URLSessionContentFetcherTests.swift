//
//  URLSessionContentFetcherTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

struct URLSessionContentFetcherTests {
    private let path = "books/en/books.json"

    /// Builds a fetcher on a unique host and registers `handler` for it.
    private func makeFetcher(
        handler: @escaping HostStubURLProtocol.Handler
    ) -> URLSessionContentFetcher {
        let host = "\(UUID().uuidString.lowercased()).test"
        HostStubURLProtocol.register(host: host, handler: handler)
        let baseURL = URL(string: "https://\(host)/repo/main/")!
        return URLSessionContentFetcher(baseURL: baseURL, session: HostStubURLProtocol.makeSession())
    }

    private static func response(
        for request: URLRequest,
        status: Int,
        headers: [String: String] = [:]
    ) -> HTTPURLResponse {
        HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers)!
    }

    @Test func sendsIfNoneMatchWhenETagGiven() async throws {
        let fetcher = makeFetcher { request in
            #expect(request.value(forHTTPHeaderField: "If-None-Match") == "\"x\"")
            #expect(request.url?.path() == "/repo/main/books/en/books.json")
            return (Self.response(for: request, status: 304), Data())
        }
        _ = try await fetcher.fetch(path: path, etag: "\"x\"")
    }

    @Test func omitsIfNoneMatchWithoutETag() async throws {
        let fetcher = makeFetcher { request in
            #expect(request.value(forHTTPHeaderField: "If-None-Match") == nil)
            return (Self.response(for: request, status: 200), Data())
        }
        _ = try await fetcher.fetch(path: path, etag: nil)
    }

    @Test func status304IsNotModified() async throws {
        let fetcher = makeFetcher { request in
            (Self.response(for: request, status: 304), Data())
        }
        #expect(try await fetcher.fetch(path: path, etag: "\"x\"") == .notModified)
    }

    @Test func status200ReturnsBodyAndETag() async throws {
        let body = Data("[1,2]".utf8)
        let fetcher = makeFetcher { request in
            (Self.response(for: request, status: 200, headers: ["ETag": "W/\"abc\""]), body)
        }
        #expect(try await fetcher.fetch(path: path, etag: nil) == .modified(body, etag: "W/\"abc\""))
    }

    @Test func status200WithoutETagHasNilETag() async throws {
        let fetcher = makeFetcher { request in
            (Self.response(for: request, status: 200), Data())
        }
        #expect(try await fetcher.fetch(path: path, etag: nil) == .modified(Data(), etag: nil))
    }

    @Test(arguments: [404, 500])
    func errorStatusThrows(status: Int) async {
        let fetcher = makeFetcher { request in
            (Self.response(for: request, status: status), Data())
        }
        await #expect(throws: ContentFetchError.badStatus(status)) {
            try await fetcher.fetch(path: path, etag: nil)
        }
    }
}
