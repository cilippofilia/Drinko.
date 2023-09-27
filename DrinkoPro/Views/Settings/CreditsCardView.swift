//
//  CreditsCardView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/06/2023.
//

import SwiftUI

struct CreditsCardView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var image: String
    var name: String
    var brief: String
    var url: String

    var body: some View {
        Button(action: {
            if UIApplication.shared.canOpenURL(URL(string: url)!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: url)!,
                                              options: [:],
                                              completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: url)!)
                }
            } else {
                //redirect to safari because the user doesn't have Instagram app
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: url)!,
                                              options: [:],
                                              completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: url)!)
                }
            }
        }) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image(systemName: image)
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
            .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview {
    VStack {
        CreditsCardView(image: "heart",
                        name: "Test",
                        brief: "@thisisatest",
                        url: "disTest??")
        CreditsCardView(image: "heart",
                        name: "Test",
                        brief: "@thisisatest",
                        url: "disTest??")

    }
}
