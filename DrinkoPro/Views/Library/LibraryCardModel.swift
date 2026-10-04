//
//  LibraryCardModel.swift
//  DrinkoPro
//

import SwiftUI

/// Display data for one item shown by `LibraryView`, independent of the model it came from.
struct LibraryCardModel: Hashable {
    var title: String
    var subtitle: String?
    var image: LibraryImage
    var imageContentMode: ContentMode
    /// Completion between 0 and 1. `nil` hides the completion bar.
    var progress: Double?

    init(
        title: String,
        subtitle: String? = nil,
        image: LibraryImage,
        imageContentMode: ContentMode = .fill,
        progress: Double? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageContentMode = imageContentMode
        self.progress = progress
    }
}
