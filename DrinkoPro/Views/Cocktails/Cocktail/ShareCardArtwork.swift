//
//  ShareCardArtwork.swift
//  DrinkoPro
//

import CoreGraphics

/// Share card artwork that's already loaded, so `ImageRenderer` can draw it synchronously.
enum ShareCardArtwork {
    case sticker(CGImage, tint: String?)
    case photo(CGImage)
    case glass(LibraryImage, tint: String?)
    case userPhoto(CGImage)
}
