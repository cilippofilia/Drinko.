//
//  MacSettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct MacSettingsView: View {
    @Environment(\.openURL) var openURL

    @State private var showOptions = false
    private let email = "cilia.filippo.dev@gmail.com"
    private let reportBugSubject = "Bug Report"
    private let reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
    private let requestFeatureSubject = "Featuristic idea"
    private let requestFeatureBody = ""
    private let contactDevSubject = ""
    private let contactDevBody = ""

    static let settingsTag: String? = "Settings"

    var body: some View {
        let languageCode = Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN"

        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        Text(languageCode)
                            .foregroundStyle(.secondary)
                            .padding(.trailing)
                    } label: {
                        Button {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.Localization-Settings") {
                                openURL(url)
                            }
                        } label: {
                            MacSettingsRowView(icon: "character.bubble", color: .primary, itemName: "Language")
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens macOS language settings.")
                    }
                } header: {
                    Text("Preferences")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        showOptions = true
                    } label: {
                        MacSettingsRowView(icon: "envelope", color: .primary, itemName: "Contact the developer")
                    }
                    .buttonStyle(.plain)
                    .confirmationDialog(
                        "Select an option",
                        isPresented: $showOptions,
                        titleVisibility: .visible
                    ) {
                        Button("Report a bug") {
                            openMail(subject: reportBugSubject, body: reportBugBody)
                        }

                        Button("Request a Feature") {
                            openMail(subject: requestFeatureSubject, body: requestFeatureBody)
                        }

                        Button("Other Enquiry") {
                            openMail(subject: contactDevSubject, body: contactDevBody)
                        }
                    }

                    Button {
                        if let rateURL {
                            openURL(rateURL)
                        }
                    } label: {
                        MacSettingsRowView(
                            icon: "star.fill",
                            color: .yellow,
                            itemName: "Rate the app"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the App Store rating page.")
                } header: {
                    Text("Support")
                        .foregroundStyle(.secondary)
                }

                MacSettingsInfoView()
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
        }
    }

    private func openMail(subject: String, body: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]

        if let url = components.url {
            openURL(url)
        }
    }
}

#if DEBUG
#Preview {
    MacSettingsView()
        .environment(Favorites())
}
#endif
