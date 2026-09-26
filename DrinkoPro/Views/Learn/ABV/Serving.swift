//
//  Serving.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

/// How a cocktail is served, which affects how much dilution it picks up.
enum Serving: CaseIterable, Identifiable {
    case up
    case rocks
    case crushed

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .up: "Up"
        case .rocks: "On the rocks"
        case .crushed: "Crushed Ice"
        }
    }
}
