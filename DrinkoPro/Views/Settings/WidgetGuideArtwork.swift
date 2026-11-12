//
//  WidgetGuideArtwork.swift
//  DrinkoPro
//

import SwiftUI

/// Three cocktail stickers fanned out above the widget guide's intro.
struct WidgetGuideArtwork: View {
    private static let stickers: [(name: String, angle: Double)] = [
        ("aperol-spritz", -10),
        ("dry-martini", 0),
        ("americano-cocktail", 10)
    ]

    var body: some View {
        HStack(spacing: -24) {
            ForEach(Self.stickers, id: \.name) { sticker in
                // Offline, the panel is simply left empty rather than showing three error badges.
                StickerImageView(url: stickerURL(sticker.name), showsBackdrop: false) { Color.clear }
                    .rotationEffect(.degrees(sticker.angle))
                    .zIndex(sticker.angle == 0 ? 1 : 0)
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(.tint.opacity(0.15), in: .rect(cornerRadius: 16))
    }

    private func stickerURL(_ name: String) -> URL? {
        URL(string: "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main/drinko-\(name).png")
    }
}

#Preview {
    WidgetGuideArtwork()
        .padding()
}
