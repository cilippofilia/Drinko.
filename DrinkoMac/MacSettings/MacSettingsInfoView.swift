//
//  MacSettingsInfoView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct MacSettingsInfoView: View {
    @State private var showReadMeView: Bool = false

    var body: some View {
        Section {
            MacSettingsRowView(
                icon: "r.circle",
                color: .secondary,
                itemName: "Read me"
            )
            .onTapGesture {
                showReadMeView.toggle()
            }

            ShareLink(item: drinkoURL!) {
                MacSettingsRowView(
                    icon: "square.and.arrow.up",
                    color: .secondary,
                    itemName: "Share the app"
                )
            }
            .buttonStyle(.plain)

            HStack {
                MacSettingsRowView(
                    icon: "v.circle",
                    color: .secondary,
                    itemName: "Version"
                )

                Text("\(getCurrentAppVersion())")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Info")
                .foregroundStyle(.secondary)
        } footer: {
            Text(lovelyText)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $showReadMeView) {
            MacReadMeView()
        }
    }

    // Get current Version of the App function
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }
}

#if DEBUG
#Preview {
    Form {
        MacSettingsInfoView()
    }
}
#endif
