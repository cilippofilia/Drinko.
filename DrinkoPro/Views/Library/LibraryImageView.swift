//
//  LibraryImageView.swift
//  DrinkoPro
//

import SwiftUI

/// Renders a `LibraryImage`. Remote photos sit on white (cocktail photos have white backgrounds);
/// fitted assets and symbols sit on a tinted fill.
struct LibraryImageView: View {
    let image: LibraryImage
    let contentMode: ContentMode

    var body: some View {
        Group {
            switch image {
            case .remote(let url):
                CachedRemoteImage(url: url, contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
            case .asset(let name):
                if contentMode == .fit {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.fill.tertiary)
                } else {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            case .symbol(let name):
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.fill.tertiary)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack {
        LibraryImageView(image: .symbol("wineglass"), contentMode: .fit)
        LibraryImageView(image: .asset("coupe"), contentMode: .fit)
        LibraryImageView(image: .asset("lime"), contentMode: .fill)
    }
    .frame(height: 100)
}
#endif
