//
//  RecentsDeckView.swift
//  DrinkoPro
//

import SwiftUI

/// The "Last Read" / "Last Viewed" carousel: up to five stacked cards that swipe like a deck,
/// with the cards behind the front one fanning out alternately to the right and left.
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
    /// Locked for the lifetime of a single drag, so a gesture that starts vertical can't
    /// later be reinterpreted as horizontal (or vice versa) as the finger wanders.
    @State private var dragAxis: Axis?
    /// `true` once the current (or just-ended) drag was recognized as a horizontal swipe,
    /// so the front card's own `Button` action knows to ignore the resulting tap/release.
    @State private var didDrag = false
    /// The current drag's starting point. `onChanged` compares against this (rather than
    /// relying on `onEnded`, which SwiftUI never calls for a cancelled gesture, e.g. one a
    /// parent scroll view takes over) to detect that a new drag has begun and reset state.
    @State private var dragStartLocation: CGPoint?

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
        let peekSteps = CGFloat(RecentsDeckLayout.peekSteps(forPosition: position))
        let tilt: Double = reduceMotion ? 0 : (isFront ? Double(dragOffset / 20) : Double(peekSteps) * 4)
        // Each step further back is smaller, so the outer pair reads as sitting behind the inner pair.
        let scale = 1 - 0.1 * abs(peekSteps)
        // The front card casts a deeper shadow so it reads as sitting above the peeking cards.
        let shadowRadius: CGFloat = isFront ? 16 : 6

        return Button {
            // A swipe can end with the front card's bounds under the touch-up point
            // (it tracks the drag via `.offset`); don't let that register as a tap.
            // `didDrag` is also cleared, asynchronously, from the gesture's `onEnded`, so
            // this guard only needs to protect the same touch-up that set it.
            guard !didDrag else { return }
            onOpen(item)
        } label: {
            LibraryCardView(model: cardModel(item), isSelected: false)
                .shadow(color: .black.opacity(isFront ? 0.25 : 0.12), radius: shadowRadius, y: shadowRadius / 2)
        }
        .buttonStyle(.plain)
        .containerRelativeFrame(.horizontal) { length, _ in
            length * 0.6
        }
        .scaleEffect(scale)
        .visualEffect { content, proxy in
            content.offset(x: proxy.size.width * 0.2 * peekSteps)
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
                // Detect a new drag by its starting point rather than by `dragAxis == nil`:
                // SwiftUI never calls `onEnded` for a gesture a parent view takes over (e.g.
                // a vertical scroll), so that's the only reliable "this is a fresh gesture" signal.
                if dragStartLocation != value.startLocation {
                    dragStartLocation = value.startLocation
                    dragAxis = nil
                    didDrag = false
                }

                // Decide the axis once, on the first change, and stick with it for this
                // drag: a vertical scroll that starts on the deck must keep scrolling even
                // if the finger briefly wanders sideways, and vice versa.
                if dragAxis == nil {
                    let translation = value.translation
                    dragAxis = abs(translation.width) > 1.5 * abs(translation.height) ? .horizontal : .vertical
                }

                // A vertical drag isn't a swipe: ignore the rest of this gesture so the
                // enclosing scroll view keeps tracking it (no offset, no advance).
                guard dragAxis == .horizontal else { return }

                didDrag = true
                if !reduceMotion {
                    dragOffset = value.translation.width
                }
            }
            .onEnded { value in
                defer {
                    dragAxis = nil
                    dragStartLocation = nil
                    // Deferred to the next main-actor turn: the Button's own tap action (if
                    // this release also triggers it) runs synchronously with this callback and
                    // must still see `didDrag == true`; only a later, separate tap should see
                    // it cleared.
                    Task { @MainActor in didDrag = false }
                }
                guard dragAxis == .horizontal else { return }

                let shouldAdvance = abs(value.predictedEndTranslation.width) > swipeThreshold

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
