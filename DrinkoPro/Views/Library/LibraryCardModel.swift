//
//  LibraryCardModel.swift
//  DrinkoPro
//

import SwiftUI

struct LibraryCardModel: Hashable {
    var title: String
    var subtitle: String?
    var image: LibraryImage
    var imageContentMode: ContentMode
    /// Completion between 0 and 1. `nil` hides the completion bar.
    var progress: Double?
    var isFavorite: Bool
    /// `false` for artwork that already shows the title, like book covers. Only grid cards hide it.
    var showsCardTitle: Bool

    init(
        title: String,
        subtitle: String? = nil,
        image: LibraryImage,
        imageContentMode: ContentMode = .fill,
        progress: Double? = nil,
        isFavorite: Bool = false,
        showsCardTitle: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageContentMode = imageContentMode
        self.progress = progress
        self.isFavorite = isFavorite
        self.showsCardTitle = showsCardTitle
    }
}
