//
//  SettingsInfoView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import SwiftUI

struct SettingsInfoView: View {
    let lovelyText = "This app was made with ❤️ by Filippo Cilia 🇮🇹"

    var body: some View {
        Section(
            header: Text("Info").foregroundStyle(.secondary),
            footer: Text(lovelyText).foregroundStyle(.secondary)
        ) {
            NavigationLink(destination: ReadMeView()) {
                SettingsRowView(icon: "r.circle",
                                color: .secondary,
                                itemName: "Read me")
            }

            Button(action: {
                shareSheet(url: drinkoURL!)
            }) {
                SettingsRowView(icon: "square.and.arrow.up",
                                color: .secondary,
                                itemName: "Share the app")
            }

            HStack {
                SettingsRowView(icon: "v.circle",
                                color: .secondary,
                                itemName: "Version")
                Spacer()

                Text("\(getCurrentAppVersion())")
                    .foregroundColor(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }

    // Get current Version of the App function
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }

    func shareSheet(url: URL) {
        let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            windowScene.keyWindow?.rootViewController?.present(activityView, animated: true, completion: nil)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        SettingsInfoView()
    }
}
#endif
