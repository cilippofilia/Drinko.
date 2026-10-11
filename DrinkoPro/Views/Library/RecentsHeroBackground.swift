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
    /// `StickerImageView.tintOpacity`, exactly as the sticker cards do, so a band at rest
    /// matches its card pixel for pixel.
    var tint: Color? {
        guard case .color(let name) = self else { return nil }
        return Color(name)
    }

    /// The color the backdrop shows overall, for judging the text's legibility on it.
    func color(in colorScheme: ColorScheme) -> Color {
        let base = baseColor(in: colorScheme)
        guard let tint else { return base }
        return base.mix(with: tint, by: StickerImageView.tintOpacity)
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

/// The full-bleed backdrop of the recents hero band, blending between the backdrops of the two
/// items the carousel is between.
///
/// Tinted backdrops are built like the sticker cards (white with the tint washed over it) and
/// blend continuously with `Color.mix`, so swiping drifts the band from one tint to the
/// next. Photo wallpapers are heavily blurred copies of the item's photo (blurred once, ahead of time; see
/// `RecentsHeroWallpaperCache`), cross-faded by the same
/// fraction, over the neutral tone so there's something to look at while they load. A color next
/// to a photo simply cross-fades. Reduce Motion doesn't remove the change, but the caller passes
/// a fraction that jumps rather than glides (see `RecentsHeroView`), so it reads as a cross-fade.
///
/// The view fills the band; the band extends it upwards (behind the navigation bar and over a
/// pull-down) by padding it with a negative top inset, and the photo layer is scaled up from the
/// bottom edge to cover that extra height.
struct RecentsHeroBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    let lower: RecentsHeroLayout.Backdrop
    let upper: RecentsHeroLayout.Backdrop
    /// 0 shows `lower`; 1 shows `upper`.
    let fraction: Double

    /// How much the wallpaper is darkened so white text stays readable on bright photos.
    private let scrimOpacity = 0.4

    var body: some View {
        ZStack {
            lower.baseColor(in: colorScheme)
                .mix(with: upper.baseColor(in: colorScheme), by: fraction)
            RecentsHeroTintWash(lower: lower.tint, upper: upper.tint, fraction: fraction)

            wallpaper(for: lower)
                .opacity(1 - fraction)
            if upper != lower {
                wallpaper(for: upper)
                    .opacity(fraction)
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func wallpaper(for backdrop: RecentsHeroLayout.Backdrop) -> some View {
        if let url = backdrop.photoURL {
            RecentsHeroWallpaper(url: url)
                .overlay { Color.black.opacity(scrimOpacity) }
        }
    }
}

#if DEBUG
#Preview {
    RecentsHeroBackground(lower: .color("Dr. Gold"), upper: .color("Dr. Lavender"), fraction: 0.4)
}
#endif
