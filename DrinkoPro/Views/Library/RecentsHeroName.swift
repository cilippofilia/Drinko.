//
//  RecentsHeroName.swift
//  DrinkoPro
//

import SwiftUI

/// The centred item's name in huge type, drawn behind the recents carousel so the items sit in
/// front of it.
///
/// It sits in the carousel's background, so it never changes the band's height: a long name
/// wraps onto more lines (up to three) and runs down behind the items instead of shrinking.
/// When the centred item changes, the name rolls into the new one, letter by letter; with
/// Reduce Motion it cross-fades.
struct RecentsHeroName<HeroID: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let text: String
    /// Identifies the item the text names, so a change animates the text into the new name.
    let heroID: HeroID?
    /// The text's point size, already scaled for Dynamic Type by the caller.
    let fontSize: CGFloat
    let textColor: Color

    /// The most lines a long name wraps onto before it's truncated.
    private let maxLines = 3

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .heavy, design: .serif))
            .lineLimit(maxLines)
            // Take the lines the name needs rather than the height the background offers.
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(textColor)
            // Rolls the letters from one name to the next. Reduce Motion cross-fades instead.
            .contentTransition(reduceMotion ? .opacity : .numericText())
            .animation(.snappy, value: heroID)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        RecentsHeroName(text: "Adonis", heroID: 1, fontSize: 56, textColor: .primary)
        RecentsHeroName(text: "Philadelphia Fish House Punch", heroID: 2, fontSize: 56, textColor: .primary)
    }
}
#endif
