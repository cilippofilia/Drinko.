//
//  LibraryItemButton.swift
//  DrinkoPro
//

import SwiftUI

/// Callers pick the button style.
struct LibraryItemButton<Label: View, MenuContent: View>: View {
    let isSelected: Bool
    /// Selection is a tinted background behind a list row, and a tinted stroke around a grid card.
    let layout: LibraryLayout
    let action: () -> Void
    @ViewBuilder let label: Label
    @ViewBuilder let contextMenu: MenuContent

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    /// On compact widths the selection is never cleared on the way back, so a highlight there
    /// would stick to the last item opened.
    private var showsSelection: Bool {
        #if os(iOS)
        isSelected && horizontalSizeClass == .regular
        #else
        isSelected
        #endif
    }

    var body: some View {
        Button(action: action) {
            label
                .background {
                    Rectangle()
                        .fill(.tint)
                        .opacity(showsSelection && layout == .list ? 0.15 : 0)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: polaroidCornerRadius)
                        .strokeBorder(.tint, lineWidth: 2)
                        .opacity(showsSelection && layout == .grid ? 1 : 0)
                        .allowsHitTesting(false)
                }
        }
        .contextMenu { self.contextMenu }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(showsSelection ? .isSelected : [])
    }
}
