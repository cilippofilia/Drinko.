//
//  ABVRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/12/2023.
//

import SwiftUI

struct ABVRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        NavigationLink(destination: ABVCalculator()) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image("abv")
                    .frame(width: rowHeight, height: rowHeight)
                    .cornerRadius(imageCornerRadius)
            }
            
            VStack(alignment: .leading) {
                Text("ABV Calculator")
                    .font(.headline)
            }
        }
        .frame(height: rowHeight)
    }
}

#if DEBUG
#Preview {
    ABVRowView()
}
#endif
