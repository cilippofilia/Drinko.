//
//  Bottle.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

/// A single ingredient contributing volume and alcohol content to an ABV calculation.
struct Bottle: Identifiable {
    let id = UUID()
    var name: String = ""
    var amount: Double = 0.0
    var abv: Double = 0.0
}
