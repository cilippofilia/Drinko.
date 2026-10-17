//
//  RecentsHeroFavoriteBadge.swift
//  DrinkoPro
//

import SwiftUI

/// On a white circle, so it reads on any artwork or band color.
struct RecentsHeroFavoriteBadge: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.headline)
            .foregroundStyle(.red)
            .padding(8)
            .background(.white, in: .circle)
            .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
            // The carousel is one accessibility element that announces favorites itself.
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    RecentsHeroFavoriteBadge()
        .padding()
        .background(.gray)
}
#endif
