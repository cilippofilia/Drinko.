//
//  SettingsPreferenceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsPreferenceView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) var openURL

    var body: some View {
        Section(header: Text("Preferences")) {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                SettingsRowView(
                    icon: "character.bubble",
                    color: .secondary,
                    itemName: "Language"
                )
                .badge(
                    Text(Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN")
                        .foregroundStyle(.secondary)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        SettingsPreferenceView()
    }
}
#endif
