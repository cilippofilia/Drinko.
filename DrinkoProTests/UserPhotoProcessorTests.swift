import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import DrinkoPro

@Suite("UserPhotoProcessor")
struct UserPhotoProcessorTests {
    private struct ImageInfo {
        let width: Int
        let height: Int
        let type: String?
    }

    /// A solid-colour JPEG of the given size, optionally tagged with an EXIF orientation.
    private func jpeg(width: Int, height: Int, orientation: Int? = nil) throws -> Data {
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        context.setFillColor(CGColor(red: 0.8, green: 0.2, blue: 0.1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(
            data, UTType.jpeg.identifier as CFString, 1, nil
        ))
        let properties = orientation.map { [kCGImagePropertyOrientation: $0] as CFDictionary }
        CGImageDestinationAddImage(destination, image, properties)
        #expect(CGImageDestinationFinalize(destination))
        return data as Data
    }

    private func pixelSize(of data: Data) throws -> ImageInfo {
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        return ImageInfo(width: image.width, height: image.height, type: CGImageSourceGetType(source) as String?)
    }

    @Test func downscalesLargePhotosToTheStoredMaximum() async throws {
        let processed = try await UserPhotoProcessor.processedJPEG(from: jpeg(width: 4000, height: 3000))
        let size = try pixelSize(of: processed)
        #expect(size.width == 1600)
        #expect(size.height == 1200)
        #expect(size.type == UTType.jpeg.identifier)
    }

    @Test func keepsSmallPhotosAtTheirSize() async throws {
        let processed = try await UserPhotoProcessor.processedJPEG(from: jpeg(width: 800, height: 600))
        let size = try pixelSize(of: processed)
        #expect(size.width == 800)
        #expect(size.height == 600)
    }

    @Test func processorRejectsGarbage() async {
        await #expect(throws: UserPhotoProcessor.ProcessingError.self) {
            try await UserPhotoProcessor.processedJPEG(from: Data("not an image".utf8))
        }
    }

    @Test func thumbnailsFitTheRequestedSize() throws {
        let data = try jpeg(width: 1600, height: 1200)
        let thumbnail = try #require(UserPhotoProcessor.thumbnail(from: data, maxPixelSize: 400))
        #expect(max(thumbnail.width, thumbnail.height) == 400)
        #expect(UserPhotoProcessor.thumbnail(from: Data("nope".utf8), maxPixelSize: 400) == nil)
    }

    @Test func appliesEXIFOrientation() async throws {
        // Orientation 6 = rotate 90 degrees clockwise to display, so a 400x300 capture becomes 300x400.
        let processed = try await UserPhotoProcessor.processedJPEG(from: jpeg(width: 400, height: 300, orientation: 6))
        let size = try pixelSize(of: processed)
        #expect(size.width == 300)
        #expect(size.height == 400)
    }
}
