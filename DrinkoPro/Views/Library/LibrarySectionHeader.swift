//
//  LibrarySectionHeader.swift
//  DrinkoPro
//

import SwiftUI

/// A tappable section title with a chevron that collapses or expands the section.
struct LibrarySectionHeader: View {
    let title: String
    let isCollapsed: Bool
    /// `false` while searching: every section is forced open and the header can't change that.
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    .opacity(isEnabled ? 1 : 0)
                Text(title)
                Spacer()
            }
            .font(.headline)
            .frame(minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
        .accessibilityValue(value)
        .accessibilityHint(hint)
    }

    /// The expanded/collapsed state, read out after the title.
    private var value: LocalizedStringKey {
        isEnabled ? CollapsibleSectionAccessibility.value(isCollapsed: isCollapsed) : ""
    }

    private var hint: LocalizedStringKey {
        isEnabled ? CollapsibleSectionAccessibility.hint(isCollapsed: isCollapsed) : ""
    }
}

#if DEBUG
#Preview {
    VStack {
        LibrarySectionHeader(title: "Basic Lessons", isCollapsed: false, isEnabled: true) { }
        LibrarySectionHeader(title: "Books", isCollapsed: true, isEnabled: true) { }
    }
    .padding()
}
#endif
