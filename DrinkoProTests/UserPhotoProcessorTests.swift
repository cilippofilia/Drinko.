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

    @Test func flattensTransparencyOntoWhite() async throws {
        // A subject lifted out of a photo: an opaque red middle on a transparent background.
        let context = try #require(CGContext(
            data: nil, width: 40, height: 40, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.clear(CGRect(x: 0, y: 0, width: 40, height: 40))
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 10, y: 10, width: 20, height: 20))
        let transparent = try #require(context.makeImage())
        let png = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(
            png, UTType.png.identifier as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, transparent, nil)
        #expect(CGImageDestinationFinalize(destination))

        let processed = try await UserPhotoProcessor.processedJPEG(from: png as Data)

        // Read the JPEG back at full size: the corner (was transparent) must be white, like the
        // bundled stickers' backdrop, and the middle still red.
        let source = try #require(CGImageSourceCreateWithData(processed as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        var pixels = [UInt8](repeating: 0, count: 40 * 40 * 4)
        let reader = try #require(CGContext(
            data: &pixels, width: 40, height: 40, bitsPerComponent: 8, bytesPerRow: 40 * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        reader.draw(image, in: CGRect(x: 0, y: 0, width: 40, height: 40))
        let corner = Array(pixels[0..<3])
        let middle = Array(pixels[(20 * 40 + 20) * 4..<(20 * 40 + 20) * 4 + 3])
        #expect(corner.allSatisfy { $0 > 240 }, "corner was \(corner)")
        #expect(middle[0] > 200 && middle[1] < 60 && middle[2] < 60, "middle was \(middle)")
    }

    @Test func appliesEXIFOrientation() async throws {
        // Orientation 6 = rotate 90 degrees clockwise to display, so a 400x300 capture becomes 300x400.
        let processed = try await UserPhotoProcessor.processedJPEG(from: jpeg(width: 400, height: 300, orientation: 6))
        let size = try pixelSize(of: processed)
        #expect(size.width == 300)
        #expect(size.height == 400)
    }
}
