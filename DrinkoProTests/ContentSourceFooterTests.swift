//
//  ContentSourceFooterTests.swift
//  DrinkoPro
//

#if DEBUG
import Foundation
import Testing
@testable import DrinkoPro

struct ContentSourceFooterTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func bundledSaysNoCache() {
        #expect(ContentSourceFooter.description(for: .bundled, now: now) == "Content: bundled with the app (no cache yet)")
    }

    @Test func cachedShowsHowLongAgoItWasChecked() {
        let checkedAt = now.addingTimeInterval(-2 * 24 * 60 * 60)
        #expect(ContentSourceFooter.description(for: .cached(checkedAt: checkedAt), now: now)
            == "Content: cached, last checked 2 days ago")
    }

    @Test func fetchedShowsMinutesAgo() {
        let fetchedAt = now.addingTimeInterval(-3 * 60)
        #expect(ContentSourceFooter.description(for: .fetched(at: fetchedAt), now: now)
            == "Content: freshly fetched from GitHub 3 minutes ago")
    }
}
#endif
