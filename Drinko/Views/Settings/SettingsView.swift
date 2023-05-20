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
    @State private var isShowingMail = false

    @State private var setBugSubject = "I have found this bug in your app!"
    @State private var setFeatureSubject = "I have a featuristic idea for you!"
    @State private var setEmailSubject = ""

    @State private var drinkoLink = "https://www.google.com"

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
                    .buttonStyle(.plain)

                    Button(action: {
                        isShowingMail.toggle()
                    }) {
                        SettingsRowView(icon: "wand.and.rays",
                                        color: .blue,
                                        itemName: "Request feature")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMail) {
                        MailView(result: $result, setSubject: $setFeatureSubject)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        isShowingMail.toggle()
                    }) {
                        SettingsRowView(icon: "envelope",
                                        color: .secondary,
                                        itemName: "Contact the developer")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMail) {
                        MailView(result: $result, setSubject: $setEmailSubject)
                    }
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
