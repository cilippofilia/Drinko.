//
//  LibraryItemButton.swift
//  DrinkoPro
//

import SwiftUI

/// Wraps a row or card so it selects its item, offers the screen's context menu,
/// and reads as a single accessible element.
struct LibraryItemButton<Label: View, MenuContent: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label
    @ViewBuilder let contextMenu: () -> MenuContent

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(.plain)
            .contextMenu(menuItems: contextMenu)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
