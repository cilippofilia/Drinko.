//
//  RecentsDeckView.swift
//  DrinkoPro
//

import SwiftUI

/// The "Last Read" / "Last Viewed" carousel: up to five stacked cards, with the next cards
/// peeking out on the right and the previous ones on the left.
///
/// Swiping left brings in the next card, swiping right the previous one; the deck loops.
/// Tapping the front card opens it.
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

    /// How far (including predicted momentum) a drag must travel to switch to the neighboring card.
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .accessibilityHidden(true)

            ZStack {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    let offset = RecentsDeckLayout.offset(ofIndex: index, frontIndex: frontIndex, count: items.count)
                    deckCard(for: item, at: offset)
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

    /// - Parameter offset: The card's place relative to the front card; see `RecentsDeckLayout.offset`.
    private func deckCard(for item: Item, at offset: Int) -> some View {
        let isFront = offset == 0
        let steps = CGFloat(RecentsDeckLayout.fanSteps(forOffset: offset, count: items.count))
        let isTucked = !isFront && steps == 0
        let tilt: Double = reduceMotion ? 0 : (isFront ? Double(dragOffset / 20) : Double(steps) * 2)
        // Each step further from the front is smaller, so the outer pair reads as sitting
        // behind the inner pair (and a tucked card stays hidden behind the front one).
        let scale = 1 - 0.08 * CGFloat(abs(offset))
        // The front card casts a deeper shadow so it reads as sitting above the peeking cards.
        let shadowRadius: CGFloat = isFront ? 16 : (isTucked ? 0 : 6)

        return Button {
            // A swipe can end with the front card's bounds under the touch-up point
            // (it tracks the drag via `.offset`); don't let that register as a tap.
            // `didDrag` is also cleared, asynchronously, from the gesture's `onEnded`, so
            // this guard only needs to protect the same touch-up that set it.
            guard !didDrag else { return }
            onOpen(item)
        } label: {
            LibraryCardView(model: cardModel(item))
                .shadow(color: .black.opacity(isFront ? 0.25 : 0.12), radius: shadowRadius, y: shadowRadius / 2)
        }
        .buttonStyle(.libraryCard)
        .containerRelativeFrame(.horizontal) { length, _ in
            length * 0.6
        }
        .scaleEffect(scale)
        .visualEffect { content, proxy in
            content.offset(x: proxy.size.width * 0.2 * steps)
        }
        .offset(x: isFront && !reduceMotion ? dragOffset : 0)
        .rotationEffect(.degrees(tilt))
        .zIndex(Double(items.count - abs(offset)))
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

                // Swiping left pulls in the card on the right (the next one); swiping right
                // pulls in the card on the left (the previous one).
                let travel = value.predictedEndTranslation.width
                let newFrontIndex: Int? = if travel < -swipeThreshold {
                    RecentsDeckLayout.nextFront(frontIndex, count: items.count)
                } else if travel > swipeThreshold {
                    RecentsDeckLayout.previousFront(frontIndex, count: items.count)
                } else {
                    nil
                }

                withAnimation(reduceMotion ? nil : .spring(duration: 0.4)) {
                    if let newFrontIndex {
                        frontIndex = newFrontIndex
                    }
                    dragOffset = 0
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
