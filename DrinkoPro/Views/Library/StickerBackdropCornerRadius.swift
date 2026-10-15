//
//  StickerBackdropCornerRadius.swift
//  DrinkoPro
//

import SwiftUI

extension EnvironmentValues {
    /// How round a sticker's backdrop is. Matches the library cards by default; a polaroid's
    /// photo window sets its own, tighter radius so the backdrop fills the window's corners.
    @Entry var stickerBackdropCornerRadius: CGFloat = libraryCardCornerRadius
}
