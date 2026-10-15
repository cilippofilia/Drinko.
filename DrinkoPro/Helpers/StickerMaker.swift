//
//  StickerMaker.swift
//  DrinkoPro
//

import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

/// Turns a photo of a drink into a Drinko sticker, like the bundled ones: the drink lifted out,
/// a thick rounded white die-cut border, a soft drop shadow, on a transparent background.
///
/// Two stages, so the second can be tested without Vision:
/// 1. `mask(for:)` asks Vision for the foreground, so any background works.
/// 2. `composite(photo:mask:)` builds the sticker with Core Image.
nonisolated enum StickerMaker {
    enum StickerError: Error {
        case unreadableImage
        /// Vision found nothing to lift out of the photo.
        case noSubject
        case renderFailed
        case encodingFailed
    }

    /// The white border's thickness, in output pixels.
    static let border: CGFloat = 30
    /// How much the grown outline is blurred before re-sharpening, which rounds its corners.
    static let borderRoundingBlur: Float = 6
    /// The drop shadow's softness.
    static let shadowBlur: CGFloat = 14
    /// The drop shadow's strength.
    static let shadowOpacity: CGFloat = 0.30
    /// The longest side of a finished sticker, in line with the bundled ones.
    static let maxLongSide: CGFloat = 1170
    /// Room around the subject for the border and shadow.
    static let padding: CGFloat = border + shadowBlur * 2
    /// Mask alpha (out of 255) a pixel needs to count when finding the subject, so faint noise
    /// in Vision's soft mask doesn't widen the crop.
    private static let subjectThreshold: UInt8 = 26

    private static let sRGB = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
    /// Thread-safe, so one is shared by every call.
    private static let context = CIContext(options: [.outputColorSpace: sRGB])

    /// Photo data in, sticker PNG out. `@concurrent` so Vision and Core Image never block the
    /// main actor.
    @concurrent
    static func makeSticker(from photoData: Data) async throws -> Data {
        guard let photo = UserPhotoProcessor.thumbnail(
            from: photoData, maxPixelSize: UserPhotoProcessor.maxStoredPixelSize
        ) else {
            throw StickerError.unreadableImage
        }
        let mask = try await mask(for: photo)
        return try pngData(from: composite(photo: CIImage(cgImage: photo), mask: mask))
    }

    /// Vision's soft foreground mask for every subject it finds, at the photo's size. All
    /// instances are kept, so a garnish or pick Vision splits off stays on the sticker.
    static func mask(for photo: CGImage) async throws -> CIImage {
        let handler = ImageRequestHandler(photo)
        guard let observation = try await handler.perform(GenerateForegroundInstanceMaskRequest()),
              !observation.allInstances.isEmpty else {
            throw StickerError.noSubject
        }
        let buffer = try observation.generateScaledMask(
            for: observation.allInstances, scaledToImageFrom: handler
        )
        return CIImage(cvPixelBuffer: buffer)
    }

    /// Builds the sticker from a photo and a same-sized mask (subject in the red channel, 0…1).
    /// Crops to the subject, scales it to the house size, then stacks a blurred black shadow,
    /// the white border and the cut-out photo, and trims the result.
    static func composite(photo: CIImage, mask: CIImage) throws -> CGImage {
        let subjectMask = try whiteAlpha(from: mask).cropped(to: mask.extent)
        guard let subject = alphaBounds(of: subjectMask, in: mask.extent, threshold: subjectThreshold) else {
            throw StickerError.noSubject
        }

        // Scale the subject so the finished sticker's long side is `maxLongSide`.
        let scale = (maxLongSide - 2 * padding) / max(subject.width, subject.height)
        let scaledSize = CGSize(
            width: (subject.width * scale).rounded(),
            height: (subject.height * scale).rounded()
        )
        let canvas = CGRect(
            x: 0, y: 0,
            width: scaledSize.width + 2 * padding,
            height: scaledSize.height + 2 * padding
        )
        func placed(_ image: CIImage) throws -> CIImage {
            let resize = CIFilter.lanczosScaleTransform()
            resize.inputImage = image.cropped(to: subject)
                .transformed(by: CGAffineTransform(translationX: -subject.minX, y: -subject.minY))
            resize.scale = Float(scale)
            resize.aspectRatio = 1
            guard let output = resize.outputImage else { throw StickerError.renderFailed }
            return output
                .cropped(to: CGRect(origin: .zero, size: scaledSize))
                .transformed(by: CGAffineTransform(translationX: padding, y: padding))
        }

        // Transparent margin around the subject. Never `clampedToExtent()`: a glass touching
        // the photo's edge would smear outward instead of getting a border.
        let clear = CIImage(color: .clear).cropped(to: canvas)
        let maskOnCanvas = try placed(subjectMask).composited(over: clear)
        let border = try borderLayer(from: maskOnCanvas, in: canvas)
        let shadow = try shadowLayer(from: border, in: canvas)

        let cutOut = CIFilter.blendWithAlphaMask()
        cutOut.inputImage = try placed(photo)
        cutOut.backgroundImage = clear
        cutOut.maskImage = maskOnCanvas
        guard let photoLayer = cutOut.outputImage?.cropped(to: canvas) else { throw StickerError.renderFailed }

        let sticker = photoLayer
            .composited(over: border.composited(over: shadow))
            .cropped(to: canvas)
        guard let trimmed = alphaBounds(of: sticker, in: canvas, threshold: 1),
              let image = context.createCGImage(sticker, from: trimmed, format: .RGBA8, colorSpace: sRGB) else {
            throw StickerError.renderFailed
        }
        return image
    }

    /// Encodes a sticker as PNG, keeping its transparency.
    static func pngData(from image: CGImage) throws -> Data {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output, UTType.png.identifier as CFString, 1, nil
        ) else {
            throw StickerError.encodingFailed
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw StickerError.encodingFailed }
        return output as Data
    }

    // MARK: - Layers

    /// Turns a one-channel mask (value in red) into white at that alpha, which every later
    /// step can grow, blur and composite directly.
    private static func whiteAlpha(from mask: CIImage) throws -> CIImage {
        let matrix = CIFilter.colorMatrix()
        matrix.inputImage = mask
        matrix.rVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        matrix.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        matrix.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        matrix.aVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        matrix.biasVector = CIVector(x: 1, y: 1, z: 1, w: 0)
        guard let output = matrix.outputImage else { throw StickerError.renderFailed }
        return output
    }

    /// The white die-cut border: the mask grown by `border`, blurred to round its corners, then
    /// pushed back to a crisp, anti-aliased edge.
    private static func borderLayer(from mask: CIImage, in canvas: CGRect) throws -> CIImage {
        let grow = CIFilter.morphologyMaximum()
        grow.inputImage = mask
        grow.radius = Float(border)

        let round = CIFilter.gaussianBlur()
        round.inputImage = grow.outputImage?.cropped(to: canvas)
        round.radius = borderRoundingBlur

        // alpha' = (alpha - 0.5) × 6 + 0.5
        let sharpen = CIFilter.colorMatrix()
        sharpen.inputImage = round.outputImage?.cropped(to: canvas)
        sharpen.aVector = CIVector(x: 0, y: 0, z: 0, w: 6)
        sharpen.biasVector = CIVector(x: 0, y: 0, z: 0, w: -2.5)

        let clamp = CIFilter.colorClamp()
        clamp.inputImage = sharpen.outputImage
        clamp.minComponents = CIVector(x: 0, y: 0, z: 0, w: 0)
        clamp.maxComponents = CIVector(x: 1, y: 1, z: 1, w: 1)
        guard let output = clamp.outputImage else { throw StickerError.renderFailed }
        return output.cropped(to: canvas)
    }

    /// The drop shadow: the border's shape, blurred, in black at `shadowOpacity`.
    private static func shadowLayer(from border: CIImage, in canvas: CGRect) throws -> CIImage {
        let soften = CIFilter.gaussianBlur()
        soften.inputImage = border
        soften.radius = Float(shadowBlur)

        let darken = CIFilter.colorMatrix()
        darken.inputImage = soften.outputImage?.cropped(to: canvas)
        darken.rVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        darken.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        darken.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        darken.aVector = CIVector(x: 0, y: 0, z: 0, w: shadowOpacity)
        guard let output = darken.outputImage else { throw StickerError.renderFailed }
        return output.cropped(to: canvas)
    }

    /// The smallest rect, in Core Image coordinates, holding every pixel of `image` within
    /// `rect` whose alpha is at least `threshold`, or nil if there are none.
    private static func alphaBounds(of image: CIImage, in rect: CGRect, threshold: UInt8) -> CGRect? {
        let width = Int(rect.width), height = Int(rect.height)
        guard width > 0, height > 0 else { return nil }
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image, toBitmap: &pixels, rowBytes: width * 4, bounds: rect, format: .RGBA8, colorSpace: nil
        )
        var minX = width, minY = height, maxX = -1, maxY = -1
        for row in 0..<height {
            for column in 0..<width where pixels[(row * width + column) * 4 + 3] >= threshold {
                minX = min(minX, column)
                maxX = max(maxX, column)
                minY = min(minY, row)
                maxY = max(maxY, row)
            }
        }
        guard maxX >= 0 else { return nil }
        // Bitmap row 0 is the top of `rect`, while Core Image's y grows upward.
        return CGRect(
            x: rect.minX + CGFloat(minX),
            y: rect.maxY - CGFloat(maxY + 1),
            width: CGFloat(maxX - minX + 1),
            height: CGFloat(maxY - minY + 1)
        )
    }
}
