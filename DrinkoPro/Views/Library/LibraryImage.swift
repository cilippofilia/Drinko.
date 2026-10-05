//
//  LibraryImage.swift
//  DrinkoPro
//

import Foundation

/// Where a library card or row gets its artwork from.
enum LibraryImage: Hashable {
    /// A remote photo, loaded through `CachedRemoteImage`.
    case remote(URL?)
    /// A remote cocktail sticker, inset on white.
    case sticker(URL?)
    /// An image from the asset catalog.
    case asset(String)
    /// An SF Symbol name.
    case symbol(String)
}
