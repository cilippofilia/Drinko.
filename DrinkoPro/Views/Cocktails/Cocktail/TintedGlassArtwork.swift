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

    var body: some View {
        Group {
            switch artwork {
            case .asset(let name):
                Image(name)
                    .resizable()
                    .scaledToFit()
            case .symbol(let name):
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            case .remote, .sticker, .userPhoto:
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
