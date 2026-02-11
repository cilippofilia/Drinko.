//
//  SuperjuiceRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/10/2023.
//

import SwiftUI

struct SuperjuiceRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ScaledMetric private var scaledRowHeight: CGFloat = rowHeight

    let juiceType: String

    var body: some View {
        NavigationLink(destination: SuperJuiceView(typeOfJuice: juiceType)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image("\(juiceType)")
                    .resizable()
                    .scaledToFill()
                    .frame(width: scaledRowHeight, height: scaledRowHeight)
                    .cornerRadius(imageCornerRadius)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text("\(juiceType.capitalizingFirstLetter()) Superjuice")
                        .font(.headline)
                }
            }
        }
        .frame(minHeight: scaledRowHeight)
        .accessibilityHint("Opens the \(juiceType.capitalizingFirstLetter()) superjuice calculator.")
    }
}

#if DEBUG
#Preview {
    SuperjuiceRowView(juiceType: "lime")
}
#endif
