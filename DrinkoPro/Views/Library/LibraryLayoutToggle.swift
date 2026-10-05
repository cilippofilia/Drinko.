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
        Button(title, systemImage: systemImage) {
            withAnimation(.snappy) {
                layout = layout.toggled
            }
        }
    }
}
