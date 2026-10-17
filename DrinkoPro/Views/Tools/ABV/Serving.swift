//
//  Serving.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

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
