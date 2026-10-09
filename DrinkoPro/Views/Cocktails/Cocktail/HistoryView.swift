//
//  HistoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 16/05/2023.
//

import SwiftUI

struct HistoryView: View {
    let cocktail: Cocktail
    let history: History

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("History")
                    .font(.title3.bold())
                    .padding(.vertical)
                    .padding(.top)

                Text(history.text)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#if DEBUG
#Preview {
    HistoryView(cocktail: .example, history: .example)
}
#endif
