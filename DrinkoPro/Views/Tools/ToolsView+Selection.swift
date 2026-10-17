//
//  ToolsView+Selection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import Foundation

extension ToolsView {
    nonisolated enum Selection: Hashable, Identifiable {
        case abvCalculator
        case superjuice(String)

        /// Persisted, so keep it stable.
        var id: String {
            switch self {
            case .abvCalculator: "abv"
            case .superjuice(let juiceType): "superjuice:\(juiceType)"
            }
        }

        init?(id: String) {
            guard let match = ToolsLibrary.calculatorItems.first(where: { $0.id == id }) else { return nil }
            self = match
        }
    }
}
