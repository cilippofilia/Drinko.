//
//  MacSinglePageView.swift
//  DrinkoMac
//

import SwiftUI

/// A Mac page without a library column: the sidebar, then `content` as the detail column.
struct MacSinglePageView<Content: View>: View {
    @Environment(\.macColumnVisibility) private var columnVisibility

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationSplitView(columnVisibility: columnVisibility) {
            MacSidebarView()
        } detail: {
            content
        }
    }
}
