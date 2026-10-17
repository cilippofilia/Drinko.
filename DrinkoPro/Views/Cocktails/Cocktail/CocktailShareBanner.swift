//
//  CocktailShareBanner.swift
//  DrinkoPro
//

import SwiftUI

/// Uses a gradient rather than the header's blur, because materials don't render in
/// `ImageRenderer`.
struct CocktailShareBanner: View {
    let name: String
    let artwork: ShareCardArtwork

    static let height: CGFloat = 220

    var body: some View {
        ShareCardArtworkView(artwork: artwork)
            .frame(height: Self.height)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.white.opacity(0), .white.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Self.height / 2)
            }
            .overlay(alignment: .bottomLeading) {
                Text(name)
                    .font(.title.bold())
                    .lineLimit(2)
                    .padding()
            }
            .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
    }
}
