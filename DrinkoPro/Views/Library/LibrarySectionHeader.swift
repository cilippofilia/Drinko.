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
            .font(.title3.bold())
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
        .accessibilityValue(isEnabled ? (isCollapsed ? "Collapsed" : "Expanded") : "")
        .accessibilityHint(hint)
    }

    /// Two whole literal strings (rather than one with an interpolated word) so each
    /// reads naturally once translated.
    private var hint: String {
        guard isEnabled else { return "" }
        return isCollapsed ? "Double tap to expand this section." : "Double tap to collapse this section."
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
