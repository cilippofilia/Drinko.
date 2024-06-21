//
//  SettingsPreferenceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsPreferenceView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var viewModel = ChangeAppIconViewModel()

    var body: some View {
        Section(header: Text("Preferences")) {
            SettingsRowView(
                icon: "character.bubble",
                color: .secondary,
                itemName: "Language"
            )
            .badge(
                Text(Bundle.main.preferredLocalizations.first!.uppercased())
                    .foregroundColor(.secondary)
            )
            .onTapGesture {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            NavigationLink(destination: ChangeAppIconView(viewModel: viewModel)) {
                HStack {
                    SettingsRowView(
                        icon: "questionmark.app",
                        color: .secondary,
                        itemName: "Icons"
                    )
                }
            }
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
