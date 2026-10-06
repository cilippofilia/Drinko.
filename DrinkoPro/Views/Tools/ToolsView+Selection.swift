//
//  ToolsView+Selection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import Foundation

extension ToolsView {
    /// The item shown in the detail column of the Tools split view.
    enum Selection: Hashable, Identifiable {
        case abvCalculator
        case superjuice(String)

        /// A stable string identity, used for persistence.
        var id: String {
            switch self {
            case .abvCalculator: "abv"
            case .superjuice(let juiceType): "superjuice:\(juiceType)"
            }
        }
    }
}
