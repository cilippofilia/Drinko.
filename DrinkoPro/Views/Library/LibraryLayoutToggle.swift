//
//  LibraryLayoutToggle.swift
//  DrinkoPro
//

import SwiftUI

/// Toolbar button that switches a library between list and grid layouts.
struct LibraryLayoutToggle: View {
    @Binding var layout: LibraryLayout

    private var title: LocalizedStringKey {
        layout == .list ? "Grid View" : "List View"
    }

    private var systemImage: String {
        layout == .list ? "square.grid.2x2" : "list.bullet"
    }

    var body: some View {
        Button(title, systemImage: systemImage, action: toggleLayout)
    }

    /// Switches the layout. The caller (`LibraryView`) owns the animation, so Reduce Motion
    /// is honored and the switch isn't animated twice.
    private func toggleLayout() {
        layout = layout.toggled
    }
}
