//
//  ABVRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/12/2023.
//

import SwiftUI

struct ABVRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ScaledMetric private var scaledRowHeight: CGFloat = rowHeight

    var body: some View {
        NavigationLink(destination: ABVCalculator()) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image("abv")
                    .frame(width: scaledRowHeight, height: scaledRowHeight)
                    .cornerRadius(imageCornerRadius)
                    .accessibilityHidden(true)
            }
            
            VStack(alignment: .leading) {
                Text("ABV Calculator")
                    .font(.headline)
            }
        }
        .frame(minHeight: scaledRowHeight)
        .accessibilityHint("Opens the alcohol by volume calculator.")
    }
}

#if DEBUG
#Preview {
    ABVRowView()
}
#endif
