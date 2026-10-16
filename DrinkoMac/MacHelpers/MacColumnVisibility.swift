//
//  MacColumnVisibility.swift
//  DrinkoMac
//

import SwiftUI

extension EnvironmentValues {
    /// The column visibility of the Mac window's split view. Each page builds its own split
    /// view (see `MacHomePageView`), so `MacHomeView` owns this and passes it down to keep the
    /// sidebar shown or hidden across pages.
    @Entry var macColumnVisibility: Binding<NavigationSplitViewVisibility> = .constant(.all)
}
