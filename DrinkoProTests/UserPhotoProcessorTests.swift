import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import DrinkoPro

@Suite("UserPhotoProcessor")
struct UserPhotoProcessorTests {
    /// A solid-colour JPEG of the given size.
    private func jpeg(width: Int, height: Int) throws -> Data {
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        context.setFillColor(CGColor(red: 0.8, green: 0.2, blue: 0.1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return data as Data
    }

    private func pixelSize(of data: Data) throws -> (width: Int, height: Int, type: String?) {
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        return (image.width, image.height, CGImageSourceGetType(source) as String?)
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
        let thumbnail = try #require(UserPhotoProcessor.thumbnail(from: jpeg(width: 1600, height: 1200), maxPixelSize: 400))
        #expect(max(thumbnail.width, thumbnail.height) == 400)
        #expect(UserPhotoProcessor.thumbnail(from: Data("nope".utf8), maxPixelSize: 400) == nil)
    }
}
