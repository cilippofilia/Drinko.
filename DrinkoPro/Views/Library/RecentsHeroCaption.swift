//
//  RecentsHeroCaption.swift
//  DrinkoPro
//

import SwiftUI

/// The centred item's name as a plain caption under the recents carousel.
///
/// It stays on one line, shrinking a long name to fit, so the band keeps one height whatever
/// the name's length.
/// When the centred item changes, the text rolls into the new name; with Reduce Motion it
/// cross-fades.
struct RecentsHeroCaption<HeroID: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let text: String
    /// Identifies the item the text names, so a change animates the text into the new name.
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
