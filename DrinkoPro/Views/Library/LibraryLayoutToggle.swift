//
//  LibraryLayoutToggle.swift
//  DrinkoPro
//

import SwiftUI

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

    /// Not animated here: `LibraryView` owns the animation, so it isn't applied twice.
    private func toggleLayout() {
        layout = layout.toggled
    }
}
