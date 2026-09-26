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

    var body: some View {
        let content = CachedRemoteImage(url: URL(string: image), contentMode: aspectRatio)
        .frame(height: frameHeight)
        .frame(minWidth: 0, maxWidth: .infinity)
        .clipped()
        .accessibilityElement(children: .ignore)

        if let accessibilityLabel {
            content.accessibilityLabel(Text(accessibilityLabel))
        } else {
            content.accessibilityHidden(true)
        }
    }
}

#if DEBUG
#Preview {
    AsyncImageView(image: "lemon", frameHeight: 200, aspectRatio: .fit)
}
#endif
