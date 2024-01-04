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

    let cocktail: Cocktail
    let history: History

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                HStack(alignment: .center) {
                    Text("History of the cocktail:")
                        .font(.title.bold())
                        .padding(.vertical)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical)

                Text(history.text)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: regularScreenWidth)
        }
    }
}

#if DEBUG
#Preview {
    HistoryView(cocktail: .example, history: .example)
        .preferredColorScheme(.dark)
}
#endif
