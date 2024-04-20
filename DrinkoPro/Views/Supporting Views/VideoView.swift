//
//  VideoView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 13/06/2023.
//

import SwiftUI
import WebKit

struct VideoView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: youtubeURL))
    }
}

#Preview {
    VideoView(videoID: "5QQ0cDGohA0")
}
