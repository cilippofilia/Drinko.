//
//  LibraryImageView.swift
//  DrinkoPro
//

import SwiftUI

/// Renders a `LibraryImage`. Remote photos and stickers sit on white (cocktail photos have white
/// backgrounds); fitted assets and symbols sit on a tinted fill.
struct LibraryImageView: View {
    let image: LibraryImage
    let contentMode: ContentMode
    /// Insets a fitted remote photo within its white backdrop so it sits smaller in the frame.
    var insetsFittedPhoto = false
    /// Sits stickers on white. Without it, a sticker fills the frame on its own.
    var showsStickerBackdrop = true

    var body: some View {
        Group {
            switch image {
            case .remote(let url):
                CachedRemoteImage(url: url, contentMode: contentMode)
                    .padding(.all, remotePhotoPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
            case .sticker(let url):
                StickerImageView(url: url, showsBackdrop: showsStickerBackdrop)
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

    /// `nil` applies the system default padding; `0` leaves the photo edge to edge.
    private var remotePhotoPadding: CGFloat? {
        insetsFittedPhoto && contentMode == .fit ? nil : 0
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
