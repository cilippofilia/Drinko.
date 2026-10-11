import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import DrinkoPro

@MainActor
@Suite("CocktailShareItem")
struct CocktailShareItemTests {
    struct LoadFailed: Error {}

    /// A 4×4 opaque image standing in for a downloaded sticker.
    private static func sampleImage() throws -> CGImage {
        let context = try #require(CGContext(
            data: nil, width: 4, height: 4, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        return try #require(context.makeImage())
    }

    private func item(
        for cocktail: Cocktail,
        artwork: LibraryImage,
        loadImage: @escaping @Sendable (URL) async throws -> CGImage
    ) -> CocktailShareItem {
        var item = CocktailShareItem(
            cocktail: cocktail,
            artwork: artwork,
            tint: nil,
            selectedUnit: "ml",
            showsOriginalUnits: cocktail.isUserCreated
        )
        item.loadImage = loadImage
        return item
    }

    @Test func usesTheDownloadedSticker() async throws {
        let image = try Self.sampleImage()
        let item = item(
            for: .example,
            artwork: .sticker(URL(string: "https://example.com/s.png"), tint: "gin"),
            loadImage: { _ in image }
        )

        guard case .sticker(_, let tint) = await item.resolvedArtwork() else {
            Issue.record("Expected sticker artwork")
            return
        }
        #expect(tint == "gin")
    }

    @Test func fallsBackToGlassArtworkWhenDownloadFails() async {
        let item = item(
            for: .example,
            artwork: .sticker(URL(string: "https://example.com/s.png"), tint: nil),
            loadImage: { _ in throw LoadFailed() }
        )

        guard case .glass(let glass, _) = await item.resolvedArtwork() else {
            Issue.record("Expected glass fallback")
            return
        }
        #expect(glass == Cocktail.example.glassArtwork)
    }

    @Test func fallsBackToGlassArtworkWhenDownloadStalls() async {
        var item = item(
            for: .example,
            artwork: .sticker(URL(string: "https://example.com/s.png"), tint: nil),
            loadImage: { _ in
                try await Task.sleep(for: .seconds(60))
                throw LoadFailed()
            }
        )
        item.loadTimeout = .milliseconds(50)

        let clock = ContinuousClock()
        let start = clock.now
        let artwork = await item.resolvedArtwork()
        let elapsed = clock.now - start

        guard case .glass(let glass, _) = artwork else {
            Issue.record("Expected glass fallback")
            return
        }
        #expect(glass == Cocktail.example.glassArtwork)
        #expect(elapsed < .seconds(5))
    }

    @Test func userCocktailsNeverDownload() async {
        let item = item(
            for: .userCreatedExample,
            artwork: Cocktail.userCreatedExample.glassArtwork,
            loadImage: { _ in
                Issue.record("User cocktails have no remote artwork")
                throw LoadFailed()
            }
        )

        guard case .glass(let glass, _) = await item.resolvedArtwork() else {
            Issue.record("Expected glass artwork")
            return
        }
        #expect(glass == Cocktail.userCreatedExample.glassArtwork)
    }

    @Test func rendersPNGAtThreeTimesCardWidth() async throws {
        let image = try Self.sampleImage()
        let item = item(
            for: .example,
            artwork: .sticker(URL(string: "https://example.com/s.png"), tint: nil),
            loadImage: { _ in image }
        )

        let data = try await item.pngData()

        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        #expect(CGImageSourceGetType(source) as String? == UTType.png.identifier)
        let rendered = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        #expect(rendered.width == Int(CocktailShareCard.width * 3))
    }

    @Test func rendersUserCocktailCard() async throws {
        let item = item(
            for: .userCreatedExample,
            artwork: Cocktail.userCreatedExample.glassArtwork,
            loadImage: { _ in throw LoadFailed() }
        )

        let data = try await item.pngData()
        #expect(!data.isEmpty)
    }
}
