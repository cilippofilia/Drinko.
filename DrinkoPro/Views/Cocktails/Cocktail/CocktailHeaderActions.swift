//
//  CocktailHeaderActions.swift
//  DrinkoPro
//

import SwiftUI

/// The round glass buttons in the header's bottom-trailing corner: History (only when the
/// cocktail has some) and Favorite.
struct CocktailHeaderActions: View {
    let cocktail: Cocktail
    let history: History?

    @State private var showHistory = false

    var body: some View {
        HStack {
            HistoryButtonView(history: history, showHistory: $showHistory, cocktail: cocktail)
            LikeButtonView(cocktail: cocktail)
        }
        .labelStyle(.iconOnly)
        .modifier(RoundGlassButtons())
        .controlSize(.large)
        // The artwork is always light, so keep the buttons light in Dark Mode too. The sheet is
        // attached outside this scope so the history itself still follows the system appearance.
        .environment(\.colorScheme, .light)
        .sheet(isPresented: $showHistory) {
            if let history {
                HistoryView(cocktail: cocktail, history: history)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

/// Round glass buttons where available. The project still deploys to iOS 18 / macOS 15, which
/// predate `.glass`, so those fall back to bordered circles.
private struct RoundGlassButtons: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            content
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
        }
    }
}
