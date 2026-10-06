//
//  ToolsDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/10/2026.
//

import SwiftUI

/// The detail column content for a Tools selection.
struct ToolsDetailView: View {
    let selection: ToolsView.Selection

    var body: some View {
        switch selection {
        case .abvCalculator:
            ABVCalculator()
        case .superjuice(let juiceType):
            SuperJuiceView(typeOfJuice: juiceType)
        }
    }
}
