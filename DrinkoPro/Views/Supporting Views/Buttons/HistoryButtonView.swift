//
//  HistoryButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/05/2025.
//

import SwiftUI

struct HistoryButtonView: View {
    let history: History?
    let showHistory: Binding<Bool>
    let cocktail: Cocktail

    var body: some View {
        Group {
            if let history = history,
               history.text != "" {
                Button(action: {
                    showHistory.wrappedValue.toggle()
                }) {
                    Label("History", systemImage: "book")
                }
                .sheet(isPresented: showHistory) {
                    HistoryView(cocktail: cocktail, history: history)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    HistoryButtonView(history: nil, showHistory: .constant(true), cocktail: Cocktail.example)
}
#endif
