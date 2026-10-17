//
//  LibraryNavigationContainer.swift
//  DrinkoPro
//

import SwiftUI

/// A `NavigationStack` on iOS. On macOS, the window's whole split view, app sidebar included,
/// since nesting split views misplaces the detail (see `MacHomePageView`).
struct LibraryNavigationContainer<Item: Hashable, Library: View, Detail: View, Placeholder: View>: View {
    private let navigation: LibraryNavigationBindings<Item>
    private let library: Library
    private let detail: (Item) -> Detail
    private let placeholder: Placeholder
    #if os(macOS)
    @Environment(\.macColumnVisibility) private var columnVisibility
    #endif

    /// - Parameters:
    ///   - placeholder: The detail column's content while nothing is selected (macOS only).
    init(
        navigation: LibraryNavigationBindings<Item>,
        @ViewBuilder library: () -> Library,
        @ViewBuilder detail: @escaping (Item) -> Detail,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.navigation = navigation
        self.library = library()
        self.detail = detail
        self.placeholder = placeholder()
    }

    var body: some View {
        #if os(iOS)
        NavigationStack(path: navigation.path) {
            library
                .navigationDestination(for: Item.self) { detail($0) }
        }
        #else
        NavigationSplitView(
            columnVisibility: columnVisibility,
            preferredCompactColumn: navigation.preferredCompactColumn
        ) {
            MacSidebarView()
        } content: {
            library
                // Narrower than this, the recents hero's title wraps over its items.
                .navigationSplitViewColumnWidth(min: 320, ideal: 380)
        } detail: {
            // Hosted in a stack in both states, so the detail column's bar looks the same
            // with or without a selection.
            NavigationStack {
                if let selection = navigation.selection.wrappedValue {
                    detail(selection)
                        .navigationDestination(for: Item.self) { detail($0) }
                } else {
                    placeholder
                }
            }
            // Recreate the detail so pushed pages and per-page state reset on a new selection.
            .id(navigation.selection.wrappedValue)
        }
        #endif
    }
}
