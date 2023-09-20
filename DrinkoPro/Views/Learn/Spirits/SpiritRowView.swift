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
            if sizeClass == .compact {
                compactSpiritRow
            } else {
                regularSpiritRow
            }
        }
        .frame(height: sizeClass == .compact ? rowHeight : rowHeight * 2)
    }

    var compactSpiritRow: some View {
        HStack {
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

    var regularSpiritRow: some View {
        HStack(spacing: 20) {
            Image(spirit.image)
                .resizable()
                .scaledToFill()
                .frame(width: rowHeight * 1.75,
                       height: rowHeight * 1.75)
                .cornerRadius(corners * 1.75)

            VStack(alignment: .leading) {
                Text(spirit.title)
                    .font(.title.bold())

                Text(spirit.description)
                    .font(.system(.headline,
                                  design: .default,
                                  weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }
}

#Preview {
    SpiritRowView(spirit: .example)
}
