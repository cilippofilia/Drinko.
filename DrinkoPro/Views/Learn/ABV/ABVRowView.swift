//
//  ABVRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/12/2023.
//

import SwiftUI

struct ABVRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State var rowHeight: CGFloat = 45
    @State var corners: CGFloat = 10

    var body: some View {
        NavigationLink(destination: ABVCalculator()) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image("abv")
                    .frame(width: rowHeight,
                           height: rowHeight)
                    .cornerRadius(corners)
            }
            
            VStack(alignment: .leading) {
                Text("ABV Calculator")
                    .font(.headline)
            }
        }
        .frame(height: rowHeight)
    }
}

#Preview {
    ABVRowView()
}
