//
//  String-Ext.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
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

    var numberOfLines: Int {
        return self.components(separatedBy: "\n").count
    }
}
