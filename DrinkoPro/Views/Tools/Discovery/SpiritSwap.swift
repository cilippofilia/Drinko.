//
//  SpiritSwap.swift
//  DrinkoPro
//

import Foundation

/// A one-spirit substitution that turns a cocktail the cabinet can't quite make into one it can.
nonisolated struct SpiritSwap: Hashable, Sendable {
    let missing: MainSpirit
    let substitutes: [MainSpirit]

    /// Spirits that work in each other's place, in the order substitutes are suggested.
    private static let pairings: [(MainSpirit, MainSpirit)] = [
        (.gin, .vodka), (.gin, .tequila), (.whiskey, .cognac), (.whiskey, .rum), (.rum, .tequila), (.rum, .cognac)
    ]

    /// The spirits that can stand in for `spirit`, in pairing-table order.
    static func substitutes(for spirit: MainSpirit) -> [MainSpirit] {
        pairings.compactMap { first, second in
            if first == spirit { second } else if second == spirit { first } else { nil }
        }
    }

    var message: String {
        let options = substitutes.map(\.displayName).formatted(.list(type: .or))
        return String(localized: "Use \(options) instead of \(missing.displayName)")
    }
}
