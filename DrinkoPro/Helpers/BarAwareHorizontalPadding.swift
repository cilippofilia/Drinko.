//
//  BarAwareHorizontalPadding.swift
//  DrinkoPro
//

import SwiftUI

extension View {
    /// Pads the leading and trailing edges, except one next to a vertical toolbar (iPhone Duo),
    /// which the system already spaces content away from.
    @ViewBuilder
    func barAwareHorizontalPadding() -> some View {
        #if os(iOS) && canImport(SwiftUICore, _version: 8.0.85)
        if #available(iOS 27.1, *) {
            modifier(BarAwareHorizontalPadding())
        } else {
            padding(.horizontal)
        }
        #else
        padding(.horizontal)
        #endif
    }

    /// Calls `action` with the horizontal edge holding a vertical toolbar (iPhone Duo), now and
    /// whenever it changes, or with `nil` where there is none (including before iOS 27.1).
    @ViewBuilder
    func onToolbarVerticalEdgeChange(_ action: @escaping (HorizontalEdge?) -> Void) -> some View {
        #if os(iOS) && canImport(SwiftUICore, _version: 8.0.85)
        if #available(iOS 27.1, *) {
            modifier(ToolbarVerticalEdgeReader(action: action))
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// `toolbarVerticalEdge` ships in the iOS 27.1 SDK (SwiftUICore 8.0.85). Xcode Cloud archives with
// the latest release Xcode, which may predate it, so this code compiles only against SDKs that have it.
#if os(iOS) && canImport(SwiftUICore, _version: 8.0.85)
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

@available(iOS 27.1, *)
private struct ToolbarVerticalEdgeReader: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge

    let action: (HorizontalEdge?) -> Void

    func body(content: Content) -> some View {
        content.onChange(of: toolbarVerticalEdge, initial: true) { _, newValue in
            action(newValue)
        }
    }
}
#endif
