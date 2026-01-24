//
//  CreditsCardView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/06/2023.
//

import SwiftUI

struct CreditsCardView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass

    var name: String
    var brief: String
    var url: String

    var body: some View {
        Button {
            openURL(URL(string: url)!)
        } label: {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(name)
                        .bold()

                    Text(brief)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }

                Spacer()

                Image(systemName: "arrow.up.forward.app")
                    .foregroundStyle(.blue)
                    .imageScale(.large)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
            .padding()
        }
        .buttonStyle(.plain)
        .background(.secondary.opacity(0.2))
        .clipShape(
            RoundedRectangle(
                cornerRadius: sizeClass == .compact ? 10 : 20,
                style: .continuous
            )
        )
    }
}

#if DEBUG
#Preview {
    LazyVGrid(columns: [
        GridItem(.flexible(minimum: 240, maximum: 480), spacing: 20, alignment: .leading),
        GridItem(.flexible(minimum: 240, maximum: 480), spacing: 20, alignment: .leading)
    ]) {
        CreditsCardView(name: "Test",
                        brief: "@thisisatest",
                        url: "disTest??")
        CreditsCardView(name: "Test",
                        brief: "@thisisatest",
                        url: "disTest??")
        CreditsCardView(name: "Test",
                        brief: "@thisisatest",
                        url: "disTest??")
        CreditsCardView(name: "Test",
                        brief: "@thisisatest",
                        url: "disTest??")
    }
}
#endif
