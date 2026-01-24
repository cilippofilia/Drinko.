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
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(minWidth: 30, minHeight: 30)

            Text(itemName)
        }
    }
}

#if DEBUG
#Preview {
    MacSettingsRowView(icon: "gear", color: .secondary, itemName: "Settings")
}
#endif
