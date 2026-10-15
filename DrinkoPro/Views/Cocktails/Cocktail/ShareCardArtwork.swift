//
//  ShareCardArtwork.swift
//  DrinkoPro
//

import CoreGraphics

/// Share card artwork that's already loaded, so `ImageRenderer` can draw it synchronously.
enum ShareCardArtwork {
    /// A downloaded sticker, inset on its tint wash.
    case sticker(CGImage, tint: String?)
    /// A downloaded photo, on white.
    case photo(CGImage)
    /// Bundled glass art (an asset or SF Symbol) on the tint wash.
    case glass(LibraryImage, tint: String?)
    /// The user's own photo, filling the banner.
    case userPhoto(CGImage)
}
