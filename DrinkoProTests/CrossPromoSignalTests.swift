//
//  CrossPromoSignalTests.swift
//  DrinkoProTests
//

import Testing
@testable import DrinkoPro

@MainActor
@Suite("CrossPromoSignal")
struct CrossPromoSignalTests {
    @Test func interstitialShowsEveryFifthBump() {
        let shown = (0...15).filter(CrossPromoSignal.shouldShowInterstitial(at:))
        #expect(shown == [5, 10, 15])
    }
}
