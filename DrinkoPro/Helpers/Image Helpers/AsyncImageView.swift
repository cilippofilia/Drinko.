//
//  AsyncImageView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct AsyncImageView: View {
    let image: String
    let frameHeight: CGFloat
    let aspectRatio: ContentMode
    var accessibilityLabel: String?
    /// Scales the image's height with the available width instead of pinning it to
    /// `frameHeight`, capped at `heroImageMaxHeight`, so a hero image isn't cropped short in a
    /// wide iPad detail column.
    var scalesWithContainer = false

    var body: some View {
        let remoteImage = CachedRemoteImage(url: URL(string: image), contentMode: aspectRatio)

        let sized = Group {
            if scalesWithContainer {
                remoteImage
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: heroImageMaxHeight)
            } else {
                remoteImage
                    .frame(height: frameHeight)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .clipped()
        .accessibilityElement(children: .ignore)

        if let accessibilityLabel {
            sized.accessibilityLabel(Text(accessibilityLabel))
        } else {
            sized.accessibilityHidden(true)
        }
    }
}

#if DEBUG
#Preview {
    AsyncImageView(image: "lemon", frameHeight: 200, aspectRatio: .fit)
}
#endif
