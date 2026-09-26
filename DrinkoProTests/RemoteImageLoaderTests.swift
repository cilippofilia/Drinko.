//
//  RemoteImageLoaderTests.swift
//  DrinkoProTests
//
//  Created by Filippo Cilia on 26/09/2026.
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import DrinkoPro

final class RemoteImageLoaderTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        await StubURLProtocol.reset()
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func makeTestImageData(pixelSize: Int = 400) throws -> Data {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: pixelSize,
            height: pixelSize,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            throw TestSetupError.imageGenerationFailed
        }

        context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))

        guard let cgImage = context.makeImage() else {
            throw TestSetupError.imageGenerationFailed
        }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            mutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw TestSetupError.imageGenerationFailed
        }

        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw TestSetupError.imageGenerationFailed
        }

        return mutableData as Data
    }

    private enum TestSetupError: Error {
        case imageGenerationFailed
    }

    func testImageIsDownsampledAndServedFromMemoryCacheOnSecondCall() async throws {
        let imageData = try makeTestImageData(pixelSize: 400)
        let url = URL(string: "https://example.com/test-image.jpg")!
        await StubURLProtocol.setResponse(for: url, data: imageData, statusCode: 200)

        let loader = RemoteImageLoader(session: makeSession())

        let first = try await loader.image(for: url, maxPixelSize: 100)
        XCTAssertLessThanOrEqual(max(first.width, first.height), 100)

        let second = try await loader.image(for: url, maxPixelSize: 100)
        XCTAssertLessThanOrEqual(max(second.width, second.height), 100)

        let requestCount = await StubURLProtocol.requestCount(for: url)
        XCTAssertEqual(requestCount, 1, "The second load should be served from the in-memory cache, not the network.")
    }

    func testNotFoundResponseThrows() async throws {
        let url = URL(string: "https://example.com/missing-image.jpg")!
        await StubURLProtocol.setResponse(for: url, data: Data(), statusCode: 404)

        let loader = RemoteImageLoader(session: makeSession())

        do {
            _ = try await loader.image(for: url, maxPixelSize: 100)
            XCTFail("Expected a 404 response to throw.")
        } catch is RemoteImageLoader.LoaderError {
            // Expected.
        }
    }
}

/// A `URLProtocol` stub that serves pre-registered responses without touching the network.
///
/// All mutable state lives behind an actor (`Registry`) so the stub is safe to drive from
/// concurrent test tasks under Swift 6 strict concurrency checking.
private final class StubURLProtocol: URLProtocol {
    private actor Registry {
        static let shared = Registry()

        private var responses: [URL: (data: Data, statusCode: Int)] = [:]
        private var counts: [URL: Int] = [:]

        func setResponse(for url: URL, data: Data, statusCode: Int) {
            responses[url] = (data, statusCode)
            counts[url] = 0
        }

        func response(for url: URL) -> (data: Data, statusCode: Int)? {
            responses[url]
        }

        func recordRequest(for url: URL) {
            counts[url, default: 0] += 1
        }

        func requestCount(for url: URL) -> Int {
            counts[url] ?? 0
        }

        func reset() {
            responses.removeAll()
            counts.removeAll()
        }
    }

    static func setResponse(for url: URL, data: Data, statusCode: Int) async {
        await Registry.shared.setResponse(for: url, data: data, statusCode: statusCode)
    }

    static func requestCount(for url: URL) async -> Int {
        await Registry.shared.requestCount(for: url)
    }

    static func reset() async {
        await Registry.shared.reset()
    }

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        Task {
            await Registry.shared.recordRequest(for: url)

            guard let stub = await Registry.shared.response(for: url) else {
                client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
                return
            }

            guard let response = HTTPURLResponse(
                url: url,
                statusCode: stub.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: stub.data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
