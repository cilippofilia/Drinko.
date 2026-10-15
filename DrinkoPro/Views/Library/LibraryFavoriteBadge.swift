//
//  LibraryFavoriteBadge.swift
//  DrinkoPro
//

import SwiftUI

/// The heart shown on a library row or card when its item is a favorite.
struct LibraryFavoriteBadge: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.headline)
            .foregroundStyle(.red)
            .transition(.symbolEffect(.appear))
            .accessibilityLabel("Favorite")
    }
}

#if DEBUG
#Preview {
    LibraryFavoriteBadge()
        .padding()
}
#endif
