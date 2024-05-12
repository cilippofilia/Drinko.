//
//  CachedImage.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/05/2024.
//

import SwiftUI

struct CachedImage<Content: View>: View {
    @StateObject private var manager = CachedImageManager()

    let url: String
    let animation: Animation?
    let transition: AnyTransition

    let content: (AsyncImagePhase) -> Content

    init(
        url: String,
        animation: Animation? = nil,
        transition: AnyTransition = .identity,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.animation = animation
        self.transition = transition
        self.content = content
    }

    var body: some View {
        ZStack {
            switch manager.currentState {
            case .loading:
                content(.empty)
                    .transition(transition)
            case .success(let data):
                if let image = UIImage(data: data) {
                    content(.success(Image(uiImage: image)))
                        .transition(transition)
                } else {
                    content(.failure(CachedImageError.invalidData))
                        .transition(transition)
                }
            case .failed(let error):
                content(.failure(error))
                    .transition(transition)
            default:
                content(.empty)
                    .transition(transition)
            }
        }
        .animation(animation, value: manager.currentState)
        .task {
            await manager.load(url)
        }
    }
}

private extension CachedImage {
    enum CachedImageError: Error {
        case invalidData
    }
}

#Preview {
    CachedImage(url: "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/abv.jpg") { _ in
        EmptyView()
    }
    .environmentObject(CachedImageManager())
}
