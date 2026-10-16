//
//  BarAwareHorizontalPadding.swift
//  DrinkoPro
//

import SwiftUI

extension View {
    /// Pads the leading and trailing edges, except one next to a vertical toolbar (iPhone Duo).
    ///
    /// The system already spaces content away from a vertical bar, and lists and forms add no
    /// margin of their own on that side. Padding it again would push this view off-centre from
    /// the content around it.
    @ViewBuilder
    func barAwareHorizontalPadding() -> some View {
        #if os(iOS)
        if #available(iOS 27.1, *) {
            modifier(BarAwareHorizontalPadding())
        } else {
            padding(.horizontal)
        }
        #else
        padding(.horizontal)
        #endif
    }
}

#if os(iOS)
@available(iOS 27.1, *)
private struct BarAwareHorizontalPadding: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge

    /// Both horizontal edges, minus the one the vertical bar sits on. The bar's side follows
    /// the device's orientation, not the layout direction, so it can't be assumed.
    private var paddedEdges: Edge.Set {
        switch toolbarVerticalEdge {
        case .leading: .trailing
        case .trailing: .leading
        case nil: .horizontal
        }
    }

    func body(content: Content) -> some View {
        content.padding(paddedEdges)
    }
}
#endif
