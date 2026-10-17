//
//  RecentsHeroBackground.swift
//  DrinkoPro
//

import SwiftUI

extension RecentsHeroLayout.Backdrop {
    /// The color under this backdrop's tint: white for a tinted backdrop, as on the sticker
    /// cards, and otherwise a quiet gray that follows the appearance (pale in light mode, deep
    /// in dark mode).
    func baseColor(in colorScheme: ColorScheme) -> Color {
        switch self {
        case .color:
            .white
        case .photo, .neutral:
            Color(white: colorScheme == .dark ? 0.16 : 0.9)
        }
    }

    /// The tint washed over the base, if any. It's laid over the base at
    /// `StickerMetrics.tintOpacity`, exactly as the sticker cards do, so a band at rest
    /// matches its card pixel for pixel.
    var tint: Color? {
        guard case .color(let name) = self else { return nil }
        return Color(name)
    }

    /// The color the backdrop shows overall, for judging the text's legibility on it.
    func color(in colorScheme: ColorScheme) -> Color {
        let base = baseColor(in: colorScheme)
        guard let tint else { return base }
        return base.mix(with: tint, by: StickerMetrics.tintOpacity)
    }

    /// How light the backdrop looks, for choosing the text color. Photos are always darkened by
    /// their scrim, so they count as dark. The colors are resolved against an environment with
    /// only the color scheme set, which keeps callers from depending on the whole environment.
    func luminance(in colorScheme: ColorScheme) -> Double {
        if photoURL != nil { return 0.1 }
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        let resolved = color(in: colorScheme).resolve(in: environment)
        return RecentsHeroLayout.luminance(
            red: Double(resolved.red),
            green: Double(resolved.green),
            blue: Double(resolved.blue)
        )
    }

    /// The photo behind this backdrop, if it has one.
    var photoURL: URL? {
        guard case .photo(let url) = self else { return nil }
        return url
    }
}

/// The full-bleed backdrop of the recents hero band for one item.
///
/// A tinted backdrop is built like the sticker cards (white with the tint washed over it), so a
/// band matches its card pixel for pixel. A photo backdrop is a heavily blurred copy of the
/// item's photo (blurred once, ahead of time; see `RecentsHeroWallpaperCache`), darkened by a
/// scrim, over the neutral tone so there's something to look at while it loads.
///
/// The view fills the band; `RecentsHeroSettledBackground` extends it upwards (behind the
/// navigation bar and over a pull-down) and cross-fades it when the centred item changes.
struct RecentsHeroBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    let backdrop: RecentsHeroLayout.Backdrop

    /// How much the wallpaper is darkened so white text stays readable on bright photos.
    private let scrimOpacity = 0.4

    var body: some View {
        ZStack {
            backdrop.baseColor(in: colorScheme)
            if let tint = backdrop.tint {
                tint.opacity(StickerMetrics.tintOpacity)
            }
            if let url = backdrop.photoURL {
                RecentsHeroWallpaper(url: url)
                    .overlay { Color.black.opacity(scrimOpacity) }
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview {
    RecentsHeroBackground(backdrop: .color("Dr. Lavender"))
}
#endif
