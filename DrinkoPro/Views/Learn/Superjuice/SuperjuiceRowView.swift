//
//  SuperjuiceRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/10/2023.
//

import SwiftUI

struct SuperjuiceRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    let juiceType: String

    var body: some View {
        NavigationLink(destination: SuperJuiceView(typeOfJuice: juiceType)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image("\(juiceType)")
                    .resizable()
                    .scaledToFill()
                    .frame(width: rowHeight, height: rowHeight)
                    .cornerRadius(imageCornerRadius)

                VStack(alignment: .leading) {
                    Text("\(juiceType.capitalizingFirstLetter()) Superjuice")
                        .font(.headline)
                }
            }
        }
        .frame(height: 45)
    }
}

#if DEBUG
#Preview {
    SuperjuiceRowView(juiceType: "lime")
}
#endif
