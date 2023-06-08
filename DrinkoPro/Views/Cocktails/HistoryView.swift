//
//  HistoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 16/05/2023.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss

    var cocktail: Cocktail

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(cocktail.name.capitalized)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
//                        .foregroundColor(.secondary)
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.vertical)

            Text(cocktail.history)
                .multilineTextAlignment(.leading)

            // spacer used to push view to the top
            Spacer()
        }
        .frame(width: screenWidthPlusMargins)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(cocktail: .example)
            .preferredColorScheme(.dark)
    }
}
