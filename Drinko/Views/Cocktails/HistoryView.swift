//
//  HistoryView.swift
//  Drinko
//
//  Created by Filippo Cilia on 16/05/2023.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss

    var cocktail: Cocktail
    var history: History

    var body: some View {
        VStack {
            if cocktail.id == history.id {
                Text(history.id.capitalized.replacingOccurrences(of: "-", with: " "))
                    .font(.title)
                    .bold()
                    .padding(.bottom)

                Text(history.text)
                    .multilineTextAlignment(.leading)

                Button(action: {
                    dismiss()
                }) {
                    Text("Dismiss")
                }
                .padding()
            }
        }
        .frame(width: screenWidthPlusMargins)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(cocktail: .example, history: .example)
    }
}
