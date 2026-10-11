//
//  LibraryImage.swift
//  DrinkoPro
//

import Foundation

/// Where a library card or row gets its artwork from.
enum LibraryImage: Hashable {
    /// A remote photo, loaded through `CachedRemoteImage`.
    case remote(URL?)
    /// A remote cocktail sticker, inset on a wash of the named color asset (white when `nil`).
    case sticker(URL?, tint: String? = nil)
    /// An image from the asset catalog.
    case asset(String)
    /// An SF Symbol name.
    case symbol(String)
    /// The user's own photo of their cocktail, drawn by `UserPhotoView`. `revision` changes
    /// whenever the photo does, so views showing the old one refresh.
    case userPhoto(id: String, revision: Int)
}
