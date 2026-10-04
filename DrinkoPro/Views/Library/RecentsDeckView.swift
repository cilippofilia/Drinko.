//
//  RecentsDeckView.swift
//  DrinkoPro
//

import SwiftUI

/// The "Last Read" / "Last Viewed" carousel: up to three stacked cards that swipe like a deck.
///
/// Swiping sends the front card to the back. Tapping the front card opens it.
struct RecentsDeckView<Item: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let items: [Item]
    let cardModel: @MainActor (Item) -> LibraryCardModel
    let onOpen: @MainActor (Item) -> Void

    @State private var frontIndex = 0
    @State private var dragOffset: CGFloat = 0

    /// How far (including predicted momentum) a drag must travel to send the card to the back.
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .accessibilityHidden(true)

            ZStack {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    let position = RecentsDeckLayout.position(ofIndex: index, frontIndex: frontIndex, count: items.count)
                    deckCard(for: item, at: position)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Swipe up or down to browse. Double tap to open.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                frontIndex = RecentsDeckLayout.nextFront(frontIndex, count: items.count)
            case .decrement:
                frontIndex = RecentsDeckLayout.previousFront(frontIndex, count: items.count)
            @unknown default:
                break
            }
        }
        .accessibilityAction {
            if let frontItem {
                onOpen(frontItem)
            }
        }
        .onChange(of: items) {
            frontIndex = 0
            dragOffset = 0
        }
    }

    private var frontItem: Item? {
        items.indices.contains(frontIndex) ? items[frontIndex] : nil
    }

    private var accessibilityLabelText: Text {
        guard let frontItem else { return Text(title) }
        return Text("\(title), \(frontIndex + 1) of \(items.count), \(cardModel(frontItem).title)")
    }

    private func deckCard(for item: Item, at position: Int) -> some View {
        let isFront = position == 0
        // Second card peeks right, third peeks left.
        let peekDirection: CGFloat = position == 1 ? 1 : (position == 2 ? -1 : 0)
        let tilt: Double = reduceMotion ? 0 : (isFront ? Double(dragOffset / 20) : Double(peekDirection) * 4)

        return Button {
            onOpen(item)
        } label: {
            LibraryCardView(model: cardModel(item), isSelected: false)
        }
        .buttonStyle(.plain)
        .containerRelativeFrame(.horizontal) { length, _ in
            length * 0.6
        }
        .scaleEffect(isFront ? 1 : 0.9)
        .visualEffect { content, proxy in
            content.offset(x: proxy.size.width * 0.3 * peekDirection)
        }
        .offset(x: isFront && !reduceMotion ? dragOffset : 0)
        .rotationEffect(.degrees(tilt))
        .zIndex(Double(items.count - position))
        .allowsHitTesting(isFront)
        .simultaneousGesture(isFront ? swipeGesture : nil)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                // Only clearly horizontal drags move the deck, so vertical scrolling keeps working.
                guard !reduceMotion, abs(value.translation.width) > abs(value.translation.height) else { return }
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                let shouldAdvance = isHorizontal && abs(value.predictedEndTranslation.width) > swipeThreshold

                if reduceMotion {
                    if shouldAdvance {
                        frontIndex = RecentsDeckLayout.nextFront(frontIndex, count: items.count)
                    }
                    dragOffset = 0
                } else {
                    withAnimation(.spring(duration: 0.4)) {
                        if shouldAdvance {
                            frontIndex = RecentsDeckLayout.nextFront(frontIndex, count: items.count)
                        }
                        dragOffset = 0
                    }
                }
            }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        RecentsDeckView(
            title: "Last Viewed",
            items: ["Negroni", "Daiquiri", "Martini"],
            cardModel: { LibraryCardModel(title: $0, image: .symbol("wineglass"), imageContentMode: .fit) },
            onOpen: { _ in }
        )
        .padding()
    }
}
#endif
