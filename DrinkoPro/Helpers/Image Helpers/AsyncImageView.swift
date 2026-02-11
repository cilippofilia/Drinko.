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
    let accessibilityLabel: String? = nil

    var body: some View {
        let content = AsyncImage(url: URL(string: image)) { state in
            switch state {
            case .empty:
                ProgressView()
            case .success(let image):
                ImageSuccesful(image: image, aspectRatio: aspectRatio)
            case .failure:
                ImageFailedToLoad()
            @unknown default:
                EmptyView()
            }
        }
        .frame(height: frameHeight)
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
