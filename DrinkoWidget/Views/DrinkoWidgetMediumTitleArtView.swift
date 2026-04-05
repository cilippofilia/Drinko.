//
//  DrinkoWidgetMediumTitleArtView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI

struct DrinkoWidgetMediumTitleArtView: View {
    let hiddenTopRow: Bool
    let hiddenMiddleRow: Bool
    let hiddenBottomRow: Bool

    var body: some View {
        VStack {
            Text("Cocktail")
                .opacity(hiddenTopRow ? 0 : 1)

            Spacer()

            HStack {
                Text("of")
                Spacer()
                Text("the")
            }
            .opacity(hiddenMiddleRow ? 0 : 1)

            Spacer()

            HStack {
                Text("D")
                Spacer()
                Text("a")
                Spacer()
                Text("y")
            }
            .opacity(hiddenBottomRow ? 0 : 1)
        }
        .textCase(.uppercase)
        .font(.system(size: 36, weight: .heavy, design: .serif))
        .foregroundStyle(.black.gradient)
        .lineLimit(3)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
