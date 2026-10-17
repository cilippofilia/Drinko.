//
//  MixingMethod.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

enum MixingMethod: CaseIterable, Identifiable {
    case built
    case shake
    case stir

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .built: "Built in the glass"
        case .shake: "Shaken"
        case .stir: "Stirred"
        }
    }
}
