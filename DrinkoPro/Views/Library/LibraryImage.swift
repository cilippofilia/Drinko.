//
//  LibraryImage.swift
//  DrinkoPro
//

import Foundation

enum LibraryImage: Hashable {
    case remote(URL?)
    /// Inset on a wash of the named color asset (white when `nil`).
    case sticker(URL?, tint: String? = nil)
    case asset(String)
    case symbol(String)
    /// `revision` changes whenever the photo does, so views showing the old one refresh.
    case userPhoto(id: String, revision: Int)
    case userSticker(id: String, revision: Int, tint: String?)
    /// An `.asset` or `.symbol` on a wash of the named color asset, for the user's cocktails
    /// without a picture.
    indirect case glass(LibraryImage, tint: String?)
}
