//
//  RecentsHeroWallpaper.swift
//  DrinkoPro
//

import SwiftUI

/// The item's photo, blurred ahead of time by `RecentsHeroWallpaperCache` so the band stays
/// cheap to redraw while it scrolls and cross-fades.
struct RecentsHeroWallpaper: View {
    let url: URL

    @State private var image: CGImage?

    var body: some View {
        // The image is only a fill: it must not size the view or spill past it.
        Color.clear
            .overlay {
                if let image {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                }
            }
            .clipped()
            .opacity(image == nil ? 0 : 1)
            .animation(.easeInOut, value: image == nil)
            .task(id: url) {
                image = await RecentsHeroWallpaperCache.shared.wallpaper(for: url)
            }
    }
}
