//
//  WidgetTutorialView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/06/2026.
//

import SwiftUI

// A short, step-by-step guide that walks users through adding the
// "Cocktail of the Day" widget to their Home Screen and customizing it.
struct WidgetTutorialView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                WidgetTutorialHeaderView()

                VStack(alignment: .leading) {
                    TutorialStepRow(
                        number: 1,
                        icon: "hand.tap",
                        title: "Touch and hold the Home Screen",
                        detail: "Press and hold an empty area until the apps start to jiggle."
                    )

                    TutorialStepRow(
                        number: 2,
                        icon: "plus.circle",
                        title: "Tap the Edit button, then Add Widget",
                        detail: "A button appears in the top corner of the screen while the apps are jiggling."
                    )

                    TutorialStepRow(
                        number: 3,
                        icon: "magnifyingglass",
                        title: "Search for Drinko",
                        detail: "Type \"Drinko\" in the search field to find the widget."
                    )

                    TutorialStepRow(
                        number: 4,
                        icon: "square.resize",
                        title: "Pick a size and add it",
                        detail: "Swipe between the small and medium widgets, then tap Add Widget."
                    )

                    TutorialStepRow(
                        number: 5,
                        icon: "slider.horizontal.3",
                        title: "Customize it",
                        detail: "Touch and hold the widget, then choose Edit Widget to change the drink source or show and hide ingredients."
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Add a Widget")
        .scrollBounceBehavior(.basedOnSize)
    }
}

// The header art and one-line pitch shown above the numbered steps.
private struct WidgetTutorialHeaderView: View {
    var body: some View {
        VStack {
            Image(systemName: "wineglass.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(.tint.opacity(0.15), in: .rect(cornerRadius: 16))

            Text("Add Drinko's \"Cocktail of the Day\" widget to your Home Screen for daily inspiration, right at a glance.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
}

// A single numbered step, paired with an SF Symbol illustrating the action.
private struct TutorialStepRow: View {
    let number: Int
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number, format: .number)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.tint, in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: icon)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        WidgetTutorialView()
    }
}
#endif
