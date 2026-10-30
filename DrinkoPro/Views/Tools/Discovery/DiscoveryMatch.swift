//
//  DiscoveryMatch.swift
//  DrinkoPro
//

import Foundation

/// A cocktail the cabinet can make, with the spirit swap it needs when it is a twist.
nonisolated struct DiscoveryMatch: Hashable, Identifiable, Sendable {
    let cocktail: Cocktail
    let swap: SpiritSwap?

    var id: String { cocktail.id }
}
