//
//  LibraryProgressBar.swift
//  DrinkoPro
//

import SwiftUI

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
