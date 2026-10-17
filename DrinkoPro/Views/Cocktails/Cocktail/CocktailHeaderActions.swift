//
//  CocktailHeaderActions.swift
//  DrinkoPro
//

import SwiftUI

struct CocktailHeaderActions: View {
    let cocktail: Cocktail
    let history: History?
    /// The appearance the History sheet is shown in. The icons sit on the header's always-light
    /// polaroid, so the sheet can't take the appearance from here.
    let sheetColorScheme: ColorScheme

    @State private var showHistory = false

    var body: some View {
        HStack {
            HistoryButtonView(history: history, showHistory: $showHistory, cocktail: cocktail)
            LikeButtonView(cocktail: cocktail)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(HeaderIconButtonStyle())
        .font(.title2)
        .sheet(isPresented: $showHistory) {
            if let history {
                // Medium only, so on iOS 26 it stays an inset sheet floating over the cocktail;
                // longer histories scroll inside it.
                HistoryView(cocktail: cocktail, history: history)
                    .presentationDetents([.medium])
                    // Applies to the sheet itself, chrome included, not just its content.
                    .preferredColorScheme(sheetColorScheme)
            }
        }
    }
}

private struct HeaderIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
