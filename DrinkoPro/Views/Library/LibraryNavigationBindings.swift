//
//  LibraryNavigationBindings.swift
//  DrinkoPro
//

import SwiftUI

/// The navigation state a screen hands to `LibraryNavigationContainer`. It differs by
/// platform, and Swift can't switch arguments with `#if`, so each screen builds one value.
struct LibraryNavigationBindings<Item: Hashable> {
    #if os(iOS)
    /// The pushed items; the first one is the page opened from the library.
    let path: Binding<[Item]>

    init(path: Binding<[Item]>) {
        self.path = path
    }
    #else
    /// The item shown in the detail column.
    let selection: Binding<Item?>
    /// The column a compact layout shows.
    let preferredCompactColumn: Binding<NavigationSplitViewColumn>

    init(selection: Binding<Item?>, preferredCompactColumn: Binding<NavigationSplitViewColumn>) {
        self.selection = selection
        self.preferredCompactColumn = preferredCompactColumn
    }
    #endif
}
