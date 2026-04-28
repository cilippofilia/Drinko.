//
//  DrinkoWidgetMediumTitleArtView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI

struct DrinkoWidgetMediumTitleArtView: View {
    @Environment(\.colorScheme) var colorScheme

    let hiddenTopRow: Bool
    let hiddenMiddleRow: Bool
    let hiddenBottomRow: Bool

    var shadowColor: Color {
        colorScheme == .dark ? .primary.opacity(0.85) : Color.clear
    }

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
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.primary)
                    .shadow(color: shadowColor, radius: 1, x: -2, y: 0)
                    .shadow(color: shadowColor, radius: 1, x: 2, y: 0)
                    .shadow(color: shadowColor, radius: 1, x: 0, y: -2)
                    .shadow(color: shadowColor, radius: 1, x: 0, y: 2)
                Spacer()
                Text("y")
            }
            .opacity(hiddenBottomRow ? 0 : 1)
        }
        .textCase(.uppercase)
        .font(.system(size: 36, weight: .heavy, design: .serif))
        .foregroundStyle(.primary)
        .lineLimit(3)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
