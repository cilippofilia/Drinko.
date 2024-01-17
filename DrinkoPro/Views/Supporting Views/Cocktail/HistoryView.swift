//
//  HistoryView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 16/05/2023.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let cocktail: Cocktail
    let history: History

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("History")
                    .font(.title3.bold())
                    .padding(.vertical)
                    .padding(.top)

                Text(history.text)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(sizeClass == .compact ? 5 : 10)
            }
            .frame(width: regularScreenWidth)
        }
    }
}

#if DEBUG
#Preview {
    HistoryView(cocktail: .example, history: .example)
}
#endif
