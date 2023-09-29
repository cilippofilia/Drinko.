//
//  HistoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 16/05/2023.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var sizeClass

    var cocktail: Cocktail

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactHistoryView
            } else {
                regularHistoryView
            }
        }
    }

    var compactHistoryView: some View {
        VStack {
            HStack(alignment: .center) {
                Text(cocktail.name.capitalized)
                    .font(.title.bold())
                    .padding(.vertical)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                        .padding(.vertical)
                }
            }
            .padding(.vertical)

            Text(cocktail.history)
                .multilineTextAlignment(.leading)

            Spacer() // spacer used to push view to the top
        }
        .frame(width: compactScreenWidth)
    }

    var regularHistoryView: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                Text("History of the cocktail:")
                    .font(.title.bold())
                    .padding(.vertical)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical)

            Text(cocktail.history)
                .multilineTextAlignment(.leading)
        }
        .frame(width: regularScreenWidth)
    }
}

#if DEBUG
#Preview {
    HistoryView(cocktail: .example)
        .preferredColorScheme(.dark)
}
#endif
