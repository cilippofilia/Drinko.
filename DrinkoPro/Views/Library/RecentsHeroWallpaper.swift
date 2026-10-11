//
//  RecentsHeroWallpaper.swift
//  DrinkoPro
//

import SwiftUI

/// A photo backdrop's wallpaper: the item's photo, blurred once ahead of time by
/// `RecentsHeroWallpaperCache`, filling the space it is given.
///
/// Showing a pre-blurred picture instead of blurring the live photo keeps the band cheap to
/// redraw while it scrolls and cross-fades. Until the picture is ready it draws nothing, so the
/// band's neutral base shows through, and it fades in when it arrives.
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
