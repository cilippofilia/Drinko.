//
//  RecentsHeroHeader.swift
//  DrinkoPro
//

import SwiftUI

/// The small uppercase label at the top of the recents band, naming the screen and the list
/// ("Cocktails · Last Viewed").
struct RecentsHeroHeader: View {
    let title: String
    let textColor: Color

    var body: some View {
        Text(title)
            .font(.footnote)
            .bold()
            .textCase(.uppercase)
            .foregroundStyle(textColor.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}
