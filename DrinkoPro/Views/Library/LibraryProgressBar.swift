//
//  LibraryProgressBar.swift
//  DrinkoPro
//

import SwiftUI

/// The optional completion bar shown under library thumbnails and cards.
struct LibraryProgressBar: View {
    let progress: Double

    var body: some View {
        ProgressView(value: min(max(progress, 0), 1))
            .progressViewStyle(.linear)
            .accessibilityLabel("Completion")
    }
}

#if DEBUG
#Preview {
    LibraryProgressBar(progress: 0.4)
        .padding()
}
#endif
