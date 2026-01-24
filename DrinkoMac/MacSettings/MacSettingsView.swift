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
    @State private var email = "cilia.filippo.dev@gmail.com"
    @State private var reportBugSubject = "Bug Report"
    @State private var reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
    @State private var requestFeatureSubject = "Featuristic idea"
    @State private var requestFeatureBody = ""
    @State private var contactDevSubject = ""
    @State private var contactDevBody = ""

    static let settingsTag: String? = "Settings"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Button {
                            openURL(URL(string: "x-apple.systempreferences:com.apple.Localization-Settings")!)
                        } label: {
                            MacSettingsRowView(
                                icon: "character.bubble",
                                color: .primary,
                                itemName: "Language"
                            )
                        }
                        .buttonStyle(.plain)

                        Text(Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN")
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                } header: {
                    Text("Preferences")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button(action: {
                        showOptions = true
                    }) {
                        MacSettingsRowView(
                            icon: "envelope",
                            color: .primary,
                            itemName: "Contact the developer"
                        )
                    }
                    .buttonStyle(.plain)
                    .confirmationDialog(
                        "Select an option",
                        isPresented: $showOptions,
                        titleVisibility: .visible
                    ) {
                        reportBug
                        requestFeature
                        otherEnquiry
                    }

                    rateApp
                } header: {
                    Text("Contacts")
                        .foregroundStyle(.secondary)
                }

                MacSettingsInfoView()
            }
            .padding()
            .navigationTitle("Settings")

            Spacer()
        }
    }

    var reportBug: some View {
        Button("Report a bug") {
            guard let url = URL(string: "mailto:\(email)?subject=\(reportBugSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(reportBugBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

            openURL(url)
        }
    }

    var requestFeature: some View {
        Button("Request a Feature") {
            guard let url = URL(string: "mailto:\(email)?subject=\(requestFeatureSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(requestFeatureBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

            openURL(url)
        }
    }

    var otherEnquiry: some View {
        Button("Other Enquiry") {
            guard let url = URL(string: "mailto:\(email)?subject=\(contactDevSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(contactDevBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

            openURL(url)
        }
    }

    var rateApp: some View {
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
    }
}

#if DEBUG
#Preview {
    MacSettingsView()
        .environment(Favorites())
}
#endif
