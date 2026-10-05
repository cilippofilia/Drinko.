//
//  StickerImageView.swift
//  DrinkoPro
//

import SwiftUI

/// A cocktail sticker, either on its own or on a white backdrop with a margin of white around it.
struct StickerImageView: View {
    let url: URL?
    /// Sits the sticker inset on white. Without it, the sticker fills the frame on its own.
    var showsBackdrop = true

    /// How much of the frame the sticker fills when it sits on its backdrop.
    private let insetScale = 0.82

    var body: some View {
        CachedRemoteImage(url: url, contentMode: .fit)
            .scaleEffect(showsBackdrop ? insetScale : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(showsBackdrop ? .white : .clear)
    }
}

#if DEBUG
#Preview {
    HStack {
        ForEach(["aperol-spritz", "americano-cocktail", "dry-martini"], id: \.self) { name in
            let base = "https://raw.githubusercontent.com/cilippofilia/Drinko-stickers/main"
            StickerImageView(url: URL(string: "\(base)/drinko-\(name).png"))
                .frame(width: 110, height: 110)
                .clipShape(.rect(cornerRadius: 10))
        }
    }
}
#endif
