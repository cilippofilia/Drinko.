//
//  CocktailHeaderActions.swift
//  DrinkoPro
//

import SwiftUI

/// The icons in line with the cocktail name in the header: History (only when the cocktail
/// has some) and Favorite.
struct CocktailHeaderActions: View {
    let cocktail: Cocktail
    let history: History?
    /// The appearance the icons are drawn in, matching the name next to them.
    let iconColorScheme: ColorScheme

    @State private var showHistory = false

    var body: some View {
        HStack {
            HistoryButtonView(history: history, showHistory: $showHistory, cocktail: cocktail)
            LikeButtonView(cocktail: cocktail)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(HeaderIconButtonStyle())
        .font(.title2)
        // The sheet is attached outside this scope so the history itself still follows the
        // system appearance.
        .environment(\.colorScheme, iconColorScheme)
        .sheet(isPresented: $showHistory) {
            if let history {
                // Medium only, so on iOS 26 it stays an inset sheet floating over the cocktail;
                // longer histories scroll inside it.
                HistoryView(cocktail: cocktail, history: history)
                    .presentationDetents([.medium])
            }
        }
    }
}

/// Bare icons in line with the cocktail name, with a full-size tap target and a dimmed
/// pressed state.
private struct HeaderIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
