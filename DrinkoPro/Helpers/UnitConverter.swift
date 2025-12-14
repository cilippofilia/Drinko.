//
//  UnitConverter.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import Foundation

@MainActor
struct UnitConverter {
    /// Converts quantity from one unit to another
    static func convert(_ quantity: Double, from fromUnit: String, to toUnit: String) -> Double {
        // If converting from oz. to ml
        if fromUnit == "oz." && toUnit == "ml" {
            return convertOzToMl(quantity)
        }
        
        // If units are the same or no conversion needed
        return quantity
    }
    
    /// Converts ounces to milliliters with standard bartending conversions
    private static func convertOzToMl(_ quantity: Double) -> Double {
        // Standard bartending conversions for common fractions
        switch quantity {
        case 1.75: return 50.0
        case 1.25: return 40.0
        case 0.75: return 25.0
        case 0.66: return 20.0
        case 0.33: return 10.0
        case 0.15: return 5.0
        default: return quantity * 30.0  // Standard oz to ml conversion
        }
    }
    
    /// Returns the appropriate unit label based on conversion
    static func unitLabel(for originalUnit: String, convertingTo targetUnit: String) -> String {
        if originalUnit == "oz." && targetUnit == "ml" {
            return "ml"
        }
        return originalUnit
    }
}
