//
//  RecentsHeroCaption.swift
//  DrinkoPro
//

import SwiftUI

/// The centred item's name under the recents carousel. It stays on one line, so the band keeps
/// one height.
struct RecentsHeroCaption<HeroID: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let text: String
    /// A change animates the text into the new name.
    let heroID: HeroID?
    let textColor: Color

    var body: some View {
        Text(text)
            .font(.title2)
            .bold()
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(textColor)
            .contentTransition(reduceMotion ? .opacity : .numericText())
            .animation(.snappy, value: heroID)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    VStack {
        RecentsHeroCaption(text: "Shaking egg white", heroID: 1, textColor: .primary)
        RecentsHeroCaption(
            text: "A very long lesson name that wraps onto a second line",
            heroID: 2,
            textColor: .primary
        )
    }
}
#endif
