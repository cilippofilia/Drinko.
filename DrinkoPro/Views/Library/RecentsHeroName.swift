//
//  RecentsHeroName.swift
//  DrinkoPro
//

import SwiftUI

/// The centred item's name in huge type, behind the recents carousel. It sits in the carousel's
/// background, so a long name runs down behind the items instead of changing the band's height.
struct RecentsHeroName<HeroID: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let text: String
    /// A change animates the text into the new name.
    let heroID: HeroID?
    /// Already scaled for Dynamic Type by the caller.
    let fontSize: CGFloat
    let textColor: Color

    private let maxLines = 3

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .heavy, design: .serif))
            .lineLimit(maxLines)
            // Take the lines the name needs rather than the height the background offers.
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(textColor)
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
