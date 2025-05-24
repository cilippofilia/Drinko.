//
//  UnselectedView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct UnselectedView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Image(systemName: "book.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue)
            Text("Welcome to Drinko Learn")
                .font(.largeTitle)
                .bold()
            Text("Select a lesson from the sidebar to get started.")
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
    UnselectedView()
}
