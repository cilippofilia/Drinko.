//
//  WidgetInk.swift
//  DrinkoWidget
//

import SwiftUI
import WidgetKit

/// In full color the widget always sits on the pale backdrop, so it uses dark ink in both
/// appearances. Tinted and clear home screens drop the backdrop and flatten colors to their
/// alpha, so there it uses hierarchical styles the system recolors.
struct WidgetInk {
    let renderingMode: WidgetRenderingMode

    private var isFullColor: Bool {
        renderingMode == .fullColor
    }

    var primary: Color {
        isFullColor ? .black : .primary
    }

    var secondary: Color {
        isFullColor ? .black.opacity(0.6) : .secondary
    }
}
