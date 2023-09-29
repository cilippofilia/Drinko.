//
//  SpiritRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 02/05/2023.
//

import SwiftUI

struct SpiritRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    var spirit: Spirit

    var body: some View {
        NavigationLink(destination: SpiritDetailView(spirit: spirit)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image(spirit.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: rowHeight,
                           height: rowHeight)
                    .cornerRadius(corners)

                VStack(alignment: .leading) {
                    Text(spirit.title)
                        .font(.headline)

                    Text(spirit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

#if DEBUG
#Preview {
    SpiritRowView(spirit: .example)
}
#endif
