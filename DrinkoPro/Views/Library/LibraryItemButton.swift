//
//  LibraryItemButton.swift
//  DrinkoPro
//

import SwiftUI

/// Wraps a row or card so it selects its item, offers the screen's context menu,
/// and reads as a single accessible element. Callers pick the button style.
struct LibraryItemButton<Label: View, MenuContent: View>: View {
    let isSelected: Bool
    /// Which layout the label is drawn in, so the selected state reads correctly:
    /// a tinted background behind a list row, a tinted stroke around a grid card.
    let layout: LibraryLayout
    let action: () -> Void
    @ViewBuilder let label: Label
    @ViewBuilder let contextMenu: MenuContent

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    /// Only highlight the selection while the detail column is on screen beside the sidebar.
    /// On compact widths the detail is pushed over the sidebar and the selection is never
    /// cleared on the way back, so a highlight there would stick to the last item opened.
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
                    RoundedRectangle(cornerRadius: libraryCardCornerRadius)
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
