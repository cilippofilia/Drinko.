//
//  RecentsHeroBackground.swift
//  DrinkoPro
//

import SwiftUI

extension RecentsHeroLayout.Backdrop {
    /// White under a tint, as on the sticker cards; otherwise a gray that follows the appearance.
    func baseColor(in colorScheme: ColorScheme) -> Color {
        switch self {
        case .color:
            .white
        case .photo, .neutral:
            Color(white: colorScheme == .dark ? 0.16 : 0.9)
        }
    }

    /// Laid over the base at `StickerMetrics.tintOpacity`, like the sticker cards, so a band at rest
    /// matches its card.
    var tint: Color? {
        guard case .color(let name) = self else { return nil }
        return Color(name)
    }

    /// For judging the text's legibility.
    func color(in colorScheme: ColorScheme) -> Color {
        let base = baseColor(in: colorScheme)
        guard let tint else { return base }
        return base.mix(with: tint, by: StickerMetrics.tintOpacity)
    }

    /// Photos are darkened by their scrim, so they count as dark.
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

    var photoURL: URL? {
        guard case .photo(let url) = self else { return nil }
        return url
    }
}

/// The recents band's backdrop for one item. A photo backdrop is a pre-blurred copy of the
/// photo (see `RecentsHeroWallpaperCache`) under a scrim, over the neutral tone while it loads.
struct RecentsHeroBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    let backdrop: RecentsHeroLayout.Backdrop

    /// Keeps white text readable on bright photos.
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
