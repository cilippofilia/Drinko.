//
//  SettingsView.swift
//  Drinko
//
//  Created by Filippo Cilia on 22/04/2023.
//

import MessageUI
import StoreKit
import SwiftUI

struct SettingsView: View {
    static let settingsTag: String? = "Settings"

    @Environment(\.requestReview) var requestReview

    @State private var result: Result<MFMailComposeResult, Error>? = nil

    @State private var email = "cilia.filippo.dev@gmail.com"
    @State private var reportBugSubject = "Bug Report"
    @State private var requestFeatureSubject = "Featuristic idea"
    @State private var contactDevSubject = ""

    @State private var drinkoLink = "https://www.google.com"

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Contacts")) {
                    Button(action: {
                        let email = email
                        let subject = reportBugSubject
                        let body = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
                        guard let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                        UIApplication.shared.open(url)
                    }) {
                        SettingsRowView(icon: "ant",
                                        color: .red,
                                        itemName: "Report a bug")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .buttonStyle(.plain)

                    Button(action: {
                        let email = email
                        let subject = requestFeatureSubject
                        let body = ""
                        guard let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                        UIApplication.shared.open(url)
                    }) {
                        SettingsRowView(icon: "wand.and.rays",
                                        color: .blue,
                                        itemName: "Request feature")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .buttonStyle(.plain)

                    Button(action: {
                        let email = email
                        let subject = contactDevSubject
                        let body = ""
                        guard let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                        UIApplication.shared.open(url)
                    }) {
                        SettingsRowView(icon: "envelope",
                                        color: .secondary,
                                        itemName: "Contact the developer")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .buttonStyle(.plain)

                }

                Section(header: Text("Support")) {
                    SettingsRowView(icon: "star",
                                    color: .yellow,
                                    itemName: "Rate the app")
                    .onTapGesture {
                        requestReview()
                    }

                    ShareLink(item: drinkoLink) {
                        SettingsRowView(icon: "square.and.arrow.up",
                                        color: .secondary,
                                        itemName: "Share the app")
                    }
                    .buttonStyle(.plain)
                }

                Section(header: Text("Info"), footer: Text("Product of Italy 🇮🇹")) {
                    NavigationLink(destination: ReadMeView()) {
                        SettingsRowView(icon: "r.circle",
                                        color: .secondary,
                                        itemName: "Read me")
                    }

//                    NavigationLink(destination: EmptyView()) {
//                        SettingsRowView(icon: "heart",
//                                        color: .red,
//                                        itemName: "Credits")
//                    }

                    HStack {
                        SettingsRowView(icon: "v.circle",
                                        color: .secondary,
                                        itemName: "Version")
                        Spacer()

                        Text("\(getCurrentAppVersion())")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }

    // Get current Version of the App function
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
