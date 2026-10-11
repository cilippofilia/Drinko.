//
//  CocktailShareItem.swift
//  DrinkoPro
//

import CoreTransferable
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

/// What the detail screen's Share button shares: a PNG of `CocktailShareCard`. The card is only
/// rendered when the share sheet asks for the data, so opening a cocktail costs nothing.
nonisolated struct CocktailShareItem: Transferable {
    enum RenderError: Error {
        case renderFailed
        case encodingFailed
    }

    let cocktail: Cocktail
    let artwork: LibraryImage
    let tint: String?
    let selectedUnit: String
    let showsOriginalUnits: Bool
    /// Downloads remote artwork. Replaced in tests.
    var loadImage: @Sendable (URL) async throws -> CGImage = { url in
        try await RemoteImageLoader.shared.image(
            for: url,
            maxPixelSize: 1080 // CocktailShareCard.width × renderScale (360 × 3)
        )
    }

    /// The pixel scale the card is rendered at.
    static let renderScale: CGFloat = 3

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            try await item.pngData()
        }
    }

    /// Loads the artwork the card shows. Falls back to the glass art when a download fails, so
    /// sharing works offline.
    @MainActor
    func resolvedArtwork() async -> ShareCardArtwork {
        switch artwork {
        case .sticker(let url?, let stickerTint):
            if let image = try? await loadImage(url) {
                return .sticker(image, tint: stickerTint)
            }
        case .remote(let url?):
            if let image = try? await loadImage(url) {
                return .photo(image)
            }
        case .asset, .symbol:
            return .glass(artwork, tint: tint)
        case .sticker(nil, _), .remote(nil):
            break
        }
        return .glass(cocktail.glassArtwork, tint: tint)
    }

    /// Renders the card and encodes it as PNG.
    @MainActor
    func pngData() async throws -> Data {
        let card = CocktailShareCard(
            cocktail: cocktail,
            artwork: await resolvedArtwork(),
            lines: cocktail.ingredients.map {
                IngredientLine(ingredient: $0, selectedUnit: selectedUnit, showsOriginalUnits: showsOriginalUnits)
            }
        )

        let renderer = ImageRenderer(content: card)
        renderer.scale = Self.renderScale
        guard let image = renderer.cgImage else { throw RenderError.renderFailed }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data, UTType.png.identifier as CFString, 1, nil
        ) else {
            throw RenderError.encodingFailed
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw RenderError.encodingFailed }
        return data as Data
    }
}
