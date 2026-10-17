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
            case .waiting:
                ProgressView()
            case .cocktail(let cocktail):
                ClipCocktailView(
                    cocktail: cocktail,
                    history: model.catalog.history(for: cocktail),
                    procedure: model.catalog.procedure(for: cocktail),
                    onReachEnd: { showsInstallPrompt = true }
                )
            case .missing:
                ClipMissingCocktailView()
            }
        }
        .appStoreOverlay(isPresented: $showsInstallPrompt) {
            SKOverlay.AppClipConfiguration(position: .bottom)
        }
        .task(id: model.content) {
            guard model.content != .waiting else { return }
            try? await Task.sleep(for: .seconds(2))
            showsInstallPrompt = true
        }
    }
}
