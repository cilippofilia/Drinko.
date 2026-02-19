//
//  MacSettingsRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct MacSettingsRowView: View {
    var icon: String
    var color: Color
    var itemName: LocalizedStringKey

    var body: some View {
        Label {
            Text(itemName)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(color)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    MacSettingsRowView(icon: "gear", color: .secondary, itemName: "Settings")
}
#endif
