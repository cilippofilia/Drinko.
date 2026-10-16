//
//  LibraryNavigationContainer.swift
//  DrinkoPro
//

import SwiftUI

/// The navigation shell shared by the Learn, Cocktails and Tools pages: a `NavigationStack`
/// on iOS, and on macOS the window's whole split view: the app sidebar (`MacSidebarView`),
/// the library, then the detail column. (Nesting this page's split view inside the window's
/// one would misplace the detail content; see `MacHomePageView`.)
///
/// The screen owns the selection state (the pushed `path` on iOS, the `selection` and
/// `preferredCompactColumn` on macOS); this view only hosts the library and its detail.
struct LibraryNavigationContainer<Item: Hashable, Library: View, Detail: View, Placeholder: View>: View {
    private let navigation: LibraryNavigationBindings<Item>
    private let library: Library
    private let detail: (Item) -> Detail
    private let placeholder: Placeholder
    #if os(macOS)
    @Environment(\.macColumnVisibility) private var columnVisibility
    #endif

    /// - Parameters:
    ///   - navigation: The screen's selection state.
    ///   - library: The library column's content, including its navigation title and toolbar.
    ///   - detail: The page for an item, used for the first page and any pushed after it.
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
