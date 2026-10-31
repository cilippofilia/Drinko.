//
//  UnitConverter.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import Foundation

@MainActor
struct UnitConverter {
    static func convert(_ quantity: Double, from fromUnit: String, to toUnit: String) -> Double {
        if fromUnit == "oz." && toUnit == "ml" {
            return convertOzToMl(quantity)
        }

        if fromUnit == "ml" && toUnit == "oz." {
            return convertMlToOz(quantity)
        }
        
        return quantity
    }
    
    /// Bartenders round an ounce to 30 ml, and jiggers measure in 5 ml steps, so the result is
    /// rounded to the nearest 5 ml (halves round up).
    private static func convertOzToMl(_ quantity: Double) -> Double {
        (quantity * 30.0 / 5).rounded() * 5
    }

    /// Rounded to the nearest quarter ounce, the smallest common jigger mark (halves round up).
    private static func convertMlToOz(_ quantity: Double) -> Double {
        (quantity / 30.0 * 4).rounded() / 4
    }
    
    static func unitLabel(for originalUnit: String, convertingTo targetUnit: String) -> String {
        if originalUnit == "oz." && targetUnit == "ml" {
            return "ml"
        }
        if originalUnit == "ml" && targetUnit == "oz." {
            return "oz."
        }
        return originalUnit
    }
}
