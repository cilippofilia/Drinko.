//
//  LibraryNavigationContainer.swift
//  DrinkoPro
//

import SwiftUI

/// The navigation shell shared by the Learn, Cocktails and Tools pages: a `NavigationStack`
/// on iOS, and a sidebar plus detail column (`NavigationSplitView`) on macOS.
///
/// The screen owns the selection state (the pushed `path` on iOS, the `selection` and
/// `preferredCompactColumn` on macOS); this view only hosts the library and its detail.
struct LibraryNavigationContainer<Item: Hashable, Library: View, Detail: View, Placeholder: View>: View {
    private let navigation: LibraryNavigationBindings<Item>
    private let library: Library
    private let detail: (Item) -> Detail
    private let placeholder: Placeholder

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
        NavigationSplitView(preferredCompactColumn: navigation.preferredCompactColumn) {
            library
        } detail: {
            // Hosted in a stack in both states, so the detail column's bar (and the sidebar
            // toggle in it) sits under the tab bar the same way.
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
