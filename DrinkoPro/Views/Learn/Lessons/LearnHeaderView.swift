//
//  LearnHeaderView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct LearnHeaderView: View {
    @Binding var isCollapsed: Bool
    let text: String

    var body: some View {
        Button {
            isCollapsed.toggle()
        } label: {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isCollapsed ? -90 : 0))
                    .animation(.snappy, value: isCollapsed)
                Text(text)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityValue(isCollapsed ? "Collapsed" : "Expanded")
        .accessibilityHint("Double tap to \(isCollapsed ? "expand" : "collapse") this section.")
    }
}

#if DEBUG
#Preview {
    LearnHeaderView(isCollapsed: .constant(false), text: "Advanced")
}
#endif
