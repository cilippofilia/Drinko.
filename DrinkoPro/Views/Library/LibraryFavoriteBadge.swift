//
//  LibraryFavoriteBadge.swift
//  DrinkoPro
//

import SwiftUI

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
