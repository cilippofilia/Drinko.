//
//  SettingsView.swift
//  Drinko
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    static let settingsTag: String? = "Settings"

    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMail = false

    @State private var setBugSubject = "I have found this bug in your app!"
    @State private var setFeatureSubject = "I have a featuristic idea for you!"
    @State private var setEmailSubject = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Contacts")) {
                    Button(action: {
                        isShowingMail.toggle()
                    }) {
                        SettingsRowView(icon: "ant",
                                        color: .red,
                                        itemName: "Report a bug")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMail) {
                        MailView(result: $result, setSubject: $setBugSubject)
                    }

                    Button(action: {

                    }) {
                        SettingsRowView(icon: "wand.and.rays",
                                        color: .secondary,
                                        itemName: "Request feature")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMail) {
                        MailView(result: $result, setSubject: $setFeatureSubject)
                    }

                    Button(action: {

                    }) {
                        SettingsRowView(icon: "envelope",
                                        color: .secondary,
                                        itemName: "Contact the developer")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMail) {
                        MailView(result: $result, setSubject: $setEmailSubject)
                    }
                }

                Section(header: Text("Info"), footer: Text("Product of Italy 🇮🇹")) {
                    NavigationLink(destination: CreditsView()) {
                        SettingsRowView(icon: "r.circle",
                                        color: .secondary,
                                        itemName: "Read me")
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
