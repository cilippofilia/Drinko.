//
//  TintedGlassArtwork.swift
//  DrinkoPro
//

import SwiftUI

/// Glass artwork (an asset or SF Symbol) on the stickers' tint wash, for cocktails without a
/// sticker or photo, like the user's own.
struct TintedGlassArtwork: View {
    let artwork: LibraryImage
    let tint: String?

    /// How much of the frame the glass fills, leaving room for the name below it.
    private let insetScale = 0.6

    /// The artwork to draw: when handed already tinted `.glass`, the glass inside it, so the
    /// wash isn't nested.
    private var glassArtwork: LibraryImage {
        if case .glass(let inner, _) = artwork { inner } else { artwork }
    }

    var body: some View {
        Group {
            switch glassArtwork {
            case .asset(let name):
                Image(name)
                    .resizable()
                    .scaledToFit()
            case .symbol(let name):
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            case .remote, .sticker, .userPhoto, .userSticker, .glass:
                Image(systemName: "wineglass")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
        .scaleEffect(insetScale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { TintWash(tint: tint) }
        // The backdrop is always light, so keep the artwork light-mode too.
        .environment(\.colorScheme, .light)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    VStack {
        TintedGlassArtwork(artwork: .asset("coupe"), tint: MainSpirit.gin.colorName)
        TintedGlassArtwork(artwork: .symbol("wineglass"), tint: nil)
    }
    .frame(height: 400)
}
#endif
