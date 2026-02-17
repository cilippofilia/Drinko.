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

        // If converting from ml to oz.
        if fromUnit == "ml" && toUnit == "oz." {
            return convertMlToOz(quantity)
        }
        
        // If units are the same or no conversion needed
        return quantity
    }
    
    /// Converts ounces to milliliters with standard bartending conversions
    private static func convertOzToMl(_ quantity: Double) -> Double {
        quantity * 30.0
    }

    /// Converts milliliters to ounces with standard bartending conversions
    private static func convertMlToOz(_ quantity: Double) -> Double {
        quantity / 30.0
    }
    
    /// Returns the appropriate unit label based on conversion
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
