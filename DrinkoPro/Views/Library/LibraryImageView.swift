//
//  LibraryImageView.swift
//  DrinkoPro
//

import SwiftUI

/// Remote photos sit on white, since cocktail photos have white backgrounds.
struct LibraryImageView: View {
    let image: LibraryImage
    let contentMode: ContentMode
    var insetsFittedPhoto = false
    /// Without it, a sticker fills the frame on its own.
    var showsStickerBackdrop = true

    var body: some View {
        Group {
            switch image {
            case .remote(let url):
                CachedRemoteImage(url: url, contentMode: contentMode)
                    .padding(.all, remotePhotoPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
            case .sticker(let url, let tint):
                StickerImageView(url: url, showsBackdrop: showsStickerBackdrop, tint: tint)
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
            case .userPhoto(let id, let revision):
                UserPhotoView(id: id, revision: revision)
            case .userSticker(let id, let revision, let tint):
                UserStickerView(id: id, revision: revision, tint: tint, showsBackdrop: showsStickerBackdrop)
            case .glass(let inner, let tint):
                TintedGlassArtwork(artwork: inner, tint: tint)
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
