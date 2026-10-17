//
//  RecentsHeroHeader.swift
//  DrinkoPro
//

import SwiftUI

/// "Cocktails · Last Viewed".
struct RecentsHeroHeader: View {
    let title: String
    let textColor: Color

    var body: some View {
        Text(title)
            // The Mac's footnote is much smaller than the iPhone's, and the label sits right
            // under the window toolbar there, so it gets a size up and a little room.
            #if os(macOS)
            .font(.subheadline)
            #else
            .font(.footnote)
            #endif
            .bold()
            .textCase(.uppercase)
            .foregroundStyle(textColor.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            #if os(macOS)
            .padding(.top, 8)
            #endif
    }
}
