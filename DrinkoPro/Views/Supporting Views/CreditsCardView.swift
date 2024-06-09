//
//  CreditsCardView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/06/2023.
//

import SwiftUI

struct CreditsCardView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var name: String
    var brief: String
    var url: String

    var body: some View {
        Button(action: {
            UIApplication.shared.open(URL(string: url)!,
                                      options: [:],
                                      completionHandler: nil)
        }) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(name)
                        .bold()

                    Text(brief)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "arrow.up.forward.app")
                    .foregroundColor(.blue)
                    .imageScale(.large)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
            .padding()
        }
        .buttonStyle(.plain)
        .background(.secondary.opacity(0.2))
        .clipShape(
            RoundedRectangle(cornerRadius: sizeClass == .compact ? 10 : 20,
                             style: .continuous)
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
