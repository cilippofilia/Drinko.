//
//  ContentSourceFooter.swift
//  DrinkoPro
//

#if DEBUG
import SwiftUI

/// Debug-only Settings footer saying whether the content is bundled, cached or freshly fetched.
struct ContentSourceFooter: View {
    /// Optional so previews without a store still render.
    @Environment(ContentStore.self) private var contentStore: ContentStore?

    var body: some View {
        // Re-renders every 30 seconds so the relative time stays current.
        TimelineView(.periodic(from: .now, by: 30)) { _ in
            Text(verbatim: Self.description(for: contentStore?.source ?? .bundled))
        }
    }

    static func description(for source: ContentSource, now: Date = .now) -> String {
        switch source {
        case .bundled:
            "Content: bundled with the app (no cache yet)"
        case .cached(let checkedAt):
            "Content: cached, last checked \(relative(checkedAt, now: now))"
        case .fetched(let fetchedAt):
            "Content: freshly fetched from GitHub \(relative(fetchedAt, now: now))"
        }
    }

    private static func relative(_ date: Date, now: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.locale = Locale(identifier: "en")
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
#endif
