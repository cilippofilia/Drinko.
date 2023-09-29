//
//  SpiritDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 02/05/2023.
//

import SwiftUI

struct SpiritDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var frameHeight: CGFloat = 280
    @State private var corners: CGFloat = 10

    var spirit: Spirit

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactSpiritView
            } else {
                regularSpiritView
            }
        }
        .navigationBarTitle(spirit.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    var compactSpiritView: some View {
        VStack {
            Image(spirit.image)
                .resizable()
                .scaledToFill()
                .frame(width: compactScreenWidth,
                       height: frameHeight)
                .clipped()

            VStack(spacing: 10) {
                Text(spirit.title)
                    .font(.title.bold())

                Text(spirit.description)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(spirit.body)
            }
            .frame(maxWidth: compactScreenWidth)
            .padding(.bottom)
        }
    }

    var regularSpiritView: some View {
        VStack(spacing: 20) {
            Image(spirit.image)
                .resizable()
                .scaledToFill()
                .frame(height: frameHeight * 1.75)
                .clipped()

            VStack(spacing: 20) {
                Text(spirit.title)
                    .font(.title.bold())

                Text(spirit.description)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(spirit.body)
            }
            .frame(maxWidth: regularScreenWidth)
            .padding(.bottom)
        }
    }
}
#if DEBUG
#Preview {
    SpiritDetailView(spirit: .example)
}
#endif
