//
//  DrinkoClipApp.swift
//  DrinkoClip
//

import SwiftUI

@main
struct DrinkoClipApp: App {
    @State private var model = ClipModel()

    var body: some Scene {
        WindowGroup {
            ClipRootView(model: model)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let url = activity.webpageURL else { return }
                    model.open(url)
                }
        }
    }
}
