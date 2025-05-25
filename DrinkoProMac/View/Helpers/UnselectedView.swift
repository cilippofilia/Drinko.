//
//  UnselectedView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct UnselectedView: View {
    let image: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue)
            Text(title)
                .font(.largeTitle)
                .bold()
            Text(subtitle)
                .font(.title2)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .multilineTextAlignment(.center)
    }
}

#Preview {
    UnselectedView(image: "book.circle", title: "This is a title", subtitle: "This is a subtitle")
}
