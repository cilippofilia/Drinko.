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

    var body: some View {
        AsyncImage(url: URL(string: image)) { state in
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
    }
}

#Preview {
    AsyncImageView(image: "lemon", frameHeight: 200, aspectRatio: .fit)
}
