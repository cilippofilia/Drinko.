//
//  WidgetInk.swift
//  DrinkoWidget
//

import SwiftUI
import WidgetKit

/// The text colors for a rendering mode. In full color the widget always sits on the
/// pale sticker backdrop, so it uses dark ink in both appearances. Tinted and clear home screens
/// drop the backdrop and flatten colors to their alpha, so there it falls back to the
/// hierarchical styles, which the system recolors.
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
