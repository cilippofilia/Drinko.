import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import DrinkoPro

@Suite("StickerMaker")
struct StickerMakerTests {
    /// A 200×300 photo: red inside `subject`, blue everywhere else, plus a mask that is white
    /// inside `subject` and black elsewhere — what Vision hands back, but exact.
    private func photoAndMask(subject: CGRect) -> (photo: CIImage, mask: CIImage) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        let photo = CIImage(color: CIColor(red: 1, green: 0, blue: 0)).cropped(to: subject)
            .composited(over: CIImage(color: CIColor(red: 0, green: 0, blue: 1)).cropped(to: frame))
        let mask = CIImage(color: CIColor(red: 1, green: 1, blue: 1)).cropped(to: subject)
            .composited(over: CIImage(color: CIColor(red: 0, green: 0, blue: 0)).cropped(to: frame))
        return (photo, mask)
    }

    /// Every pixel of `image` as RGBA8 premultiplied, row 0 at the top.
    private func pixels(of image: CGImage) throws -> [UInt8] {
        var pixels = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let context = try #require(CGContext(
            data: &pixels, width: image.width, height: image.height, bitsPerComponent: 8,
            bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return pixels
    }

    private func pixel(_ pixels: [UInt8], width: Int, x column: Int, y row: Int) -> [UInt8] {
        let start = (row * width + column) * 4
        return Array(pixels[start..<start + 4])
    }

    /// The first x in the middle row that is opaque red: the subject's left edge.
    private func subjectLeftEdge(_ pixels: [UInt8], width: Int, height: Int) throws -> Int {
        let middleRow = height / 2
        return try #require((0..<width).first { column in
            let rgba = pixel(pixels, width: width, x: column, y: middleRow)
            return rgba[0] > 200 && rgba[1] < 60 && rgba[3] == 255
        })
    }

    @Test func makesAHouseStyleSticker() throws {
        let (photo, mask) = photoAndMask(subject: CGRect(x: 50, y: 60, width: 100, height: 180))
        let sticker = try StickerMaker.composite(photo: photo, mask: mask)
        let data = try pixels(of: sticker)

        // Tall subject: the long side lands on the house size.
        #expect(sticker.height == Int(StickerMaker.maxLongSide))
        #expect(sticker.width < sticker.height)
        // Transparent corners.
        #expect(pixel(data, width: sticker.width, x: 0, y: 0) == [0, 0, 0, 0])
        // Subject centre is the photo.
        let centre = pixel(data, width: sticker.width, x: sticker.width / 2, y: sticker.height / 2)
        #expect(centre[0] > 200 && centre[1] < 60 && centre[3] == 255, "centre was \(centre)")

        let edge = try subjectLeftEdge(data, width: sticker.width, height: sticker.height)
        let row = sticker.height / 2
        // About 30 px of solid white border...
        #expect(pixel(data, width: sticker.width, x: edge - 25, y: row) == [255, 255, 255, 255])
        // ...then only a faint black shadow.
        let shadow = pixel(data, width: sticker.width, x: edge - 40, y: row)
        #expect(shadow[0] == 0 && shadow[3] > 0 && shadow[3] < 80, "shadow was \(shadow)")
    }

    @Test func trimsToTheShadow() throws {
        let (photo, mask) = photoAndMask(subject: CGRect(x: 50, y: 60, width: 100, height: 180))
        let sticker = try StickerMaker.composite(photo: photo, mask: mask)
        let data = try pixels(of: sticker)
        let width = sticker.width, height = sticker.height
        // Every outer row and column has something visible.
        #expect((0..<width).contains { pixel(data, width: width, x: $0, y: 0)[3] > 0 })
        #expect((0..<width).contains { pixel(data, width: width, x: $0, y: height - 1)[3] > 0 })
        #expect((0..<height).contains { pixel(data, width: width, x: 0, y: $0)[3] > 0 })
        #expect((0..<height).contains { pixel(data, width: width, x: width - 1, y: $0)[3] > 0 })
    }

    @Test func subjectTouchingTheEdgeStillGetsAFullBorder() throws {
        // The subject runs off the left edge of the photo.
        let (photo, mask) = photoAndMask(subject: CGRect(x: 0, y: 60, width: 100, height: 180))
        let sticker = try StickerMaker.composite(photo: photo, mask: mask)
        let data = try pixels(of: sticker)
        let edge = try subjectLeftEdge(data, width: sticker.width, height: sticker.height)
        let row = sticker.height / 2
        #expect(pixel(data, width: sticker.width, x: edge - 25, y: row) == [255, 255, 255, 255])
        #expect(pixel(data, width: sticker.width, x: edge - 40, y: row)[3] < 80)
    }

    @Test func offCentreSubjectLeaksNoBackground() throws {
        // Near the bottom, so a flipped row order would crop the wrong band.
        let (photo, mask) = photoAndMask(subject: CGRect(x: 50, y: 20, width: 100, height: 180))
        let sticker = try StickerMaker.composite(photo: photo, mask: mask)
        let data = try pixels(of: sticker)
        let blue = stride(from: 0, to: data.count, by: 4).filter { data[$0 + 2] > 150 && data[$0] < 100 }
        #expect(blue.isEmpty, "\(blue.count) background pixels leaked")
    }

    @Test func emptyMaskThrowsNoSubject() {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        let photo = CIImage(color: CIColor(red: 1, green: 0, blue: 0)).cropped(to: frame)
        let mask = CIImage(color: CIColor(red: 0, green: 0, blue: 0)).cropped(to: frame)
        #expect(throws: StickerMaker.StickerError.noSubject) {
            try StickerMaker.composite(photo: photo, mask: mask)
        }
    }

    @Test func thumbnailKeepsStickerTransparency() throws {
        let (photo, mask) = photoAndMask(subject: CGRect(x: 50, y: 60, width: 100, height: 180))
        let png = try StickerMaker.pngData(from: StickerMaker.composite(photo: photo, mask: mask))

        let source = try #require(CGImageSourceCreateWithData(png as CFData, nil))
        #expect(CGImageSourceGetType(source) as String? == UTType.png.identifier)
        let thumbnail = try #require(UserPhotoProcessor.thumbnail(from: png, maxPixelSize: 400))
        let data = try pixels(of: thumbnail)
        #expect(pixel(data, width: thumbnail.width, x: 0, y: 0)[3] == 0)
    }

    @Test func rejectsGarbage() async {
        await #expect(throws: StickerMaker.StickerError.unreadableImage) {
            try await StickerMaker.makeSticker(from: Data("not an image".utf8))
        }
    }
}
