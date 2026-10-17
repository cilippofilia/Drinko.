//
//  StickerBackdropCornerRadius.swift
//  DrinkoPro
//

import SwiftUI

extension EnvironmentValues {
    /// A polaroid's photo window sets its own, tighter radius so the backdrop fills its corners.
    @Entry var stickerBackdropCornerRadius: CGFloat = libraryCardCornerRadius
}
