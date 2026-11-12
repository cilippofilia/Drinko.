//
//  MacSettingsInfoView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import AboutSection
import SwiftUI

struct MacSettingsInfoView: View {
    @State private var showReadMeView: Bool = false

    var body: some View {
        Section {
            Button {
                showReadMeView.toggle()
            } label: {
                MacSettingsRowView(
                    icon: "r.circle",
                    color: .secondary,
                    itemName: "Read me"
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens the app guide.")

            ChangelogRow()

            ShareRow(info: drinkoAppInfo)
        } header: {
            Text("Info")
                .foregroundStyle(.secondary)
        } footer: {
            VStack {
                VersionFooter(info: drinkoAppInfo)
                #if DEBUG
                ContentSourceFooter()
                #endif
            }
            .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $showReadMeView) {
            MacReadMeView()
        }
    }
}

#if DEBUG
#Preview {
    MacSettingsInfoView()
}
#endif
