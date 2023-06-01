//
//  StringExtension.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 24/04/2023.
//

import SwiftUI

/// String extension that capitalizes the first letter of a word
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
