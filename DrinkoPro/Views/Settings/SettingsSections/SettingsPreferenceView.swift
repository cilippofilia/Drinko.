//
//  SettingsPreferenceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsPreferenceView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(IconModel.self) var iconModel: IconModel

    var body: some View {
        Section(header: Text("Preferences")) {
            HStack {
                SettingsRowView(icon: "character.bubble",
                                color: .secondary,
                                itemName: "Language")
                Spacer()

                Text(Bundle.main.preferredLocalizations.first!.uppercased())
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            NavigationLink(destination: IconsView()) {
                HStack {
                    SettingsRowView(icon: "app.gift", color: .secondary, itemName: "Icons")
                }
            }
        }
    }
}

#Preview {
    Form {
        SettingsPreferenceView()
            .environment(IconModel())
    }
}
