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
    
    /// Bartenders round an ounce to 30 ml.
    private static func convertOzToMl(_ quantity: Double) -> Double {
        quantity * 30.0
    }

    private static func convertMlToOz(_ quantity: Double) -> Double {
        quantity / 30.0
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
