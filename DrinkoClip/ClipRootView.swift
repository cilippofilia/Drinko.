//
//  ClipRootView.swift
//  DrinkoClip
//

import StoreKit
import SwiftUI

/// The App Clip's only screen: the shared cocktail, or a missing state. The full app's install
/// banner rises a moment after it appears.
struct ClipRootView: View {
    let model: ClipModel
    @State private var showsInstallPrompt = false

    var body: some View {
        NavigationStack {
            switch model.content {
            case .waiting, .loading:
                ProgressView()
            case .cocktail(let clipCocktail):
                ClipCocktailView(
                    cocktail: clipCocktail.cocktail,
                    history: clipCocktail.history,
                    procedure: clipCocktail.procedure,
                    onReachEnd: { showsInstallPrompt = true }
                )
            case .missing:
                ClipMissingCocktailView()
            }
        }
        .appStoreOverlay(isPresented: $showsInstallPrompt) {
            SKOverlay.AppClipConfiguration(position: .bottom)
        }
        .task {
            // Give the invocation URL a moment to arrive before giving up on it.
            try? await Task.sleep(for: .seconds(1))
            model.showMissingIfStillWaiting()
        }
        .task(id: model.content) {
            guard model.content != .waiting, model.content != .loading else { return }
            try? await Task.sleep(for: .seconds(2))
            showsInstallPrompt = true
        }
    }
}
