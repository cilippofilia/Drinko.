//
//  SettingsRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct SettingsRowView: View {
    var icon: String
    var color: Color
    var itemName: LocalizedStringKey

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(minWidth: 30, minHeight: 30)

            Text(itemName)
        }
    }
}

#Preview {
    SettingsRowView(icon: "gear", color: .secondary, itemName: "Settings")
}
