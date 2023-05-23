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

    @State private var email = "cilia.filippo.dev@gmail.com"

    @State private var showOptions = false

    @State private var reportBugSubject = "Bug Report"
    @State private var reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."

    @State private var requestFeatureSubject = "Featuristic idea"
    @State private var requesteFeatureBody = ""

    @State private var contactDevSubject = ""
    @State private var contactDevBody = ""

    // Check if this link works once the app is live
    @State private var drinkoLink = "https://apps.apple.com/us/app/drinko/id1525136516"
    @State private var twitterDevURL = URL(string: "https://twitter.com/fcilia_dev/")

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Support")) {
                    HStack {
                        SettingsRowView(icon: "text.bubble",
                                        color: .secondary,
                                        itemName: "Language")
                        Spacer()

                        Text(Bundle.main.preferredLocalizations.first!.uppercased())
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }

                    Button(action: {
                        showOptions = true
                    }) {
                        SettingsRowView(icon: "envelope",
                                        color: .secondary,
                                        itemName: "Contact the developer")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .buttonStyle(.plain)
                    .confirmationDialog("Select an option",
                                        isPresented: $showOptions,
                                        titleVisibility: .visible) {
                        Button("Report a bug") {
                            guard let url = URL(string: "mailto:\(email)?subject=\(reportBugSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(reportBugBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                            UIApplication.shared.open(url)
                        }

                        Button("Request a Feature") {
                            guard let url = URL(string: "mailto:\(email)?subject=\(requestFeatureSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(requesteFeatureBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                            UIApplication.shared.open(url)
                        }

                        Button("Other Enquiry") {
                            guard let url = URL(string: "mailto:\(email)?subject=\(contactDevSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(contactDevBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                            UIApplication.shared.open(url)
                        }
                    }

                    Button(action: {
                        if UIApplication.shared.canOpenURL(twitterDevURL!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(twitterDevURL!, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(twitterDevURL!)
                            }
                        } else {
                            //redirect to safari because the user doesn't have Instagram
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(twitterDevURL!, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(twitterDevURL!)
                            }
                        }
                    }) {
                        SettingsRowView(icon: "bird",
                                        color: .blue,
                                        itemName: "Twitter")
                    }
                    .buttonStyle(.plain)


                    SettingsRowView(icon: "star",
                                    color: .yellow,
                                    itemName: "Rate the app")
                    .onTapGesture {
                        requestReview()
                    }
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

                    ShareLink(item: drinkoLink) {
                        SettingsRowView(icon: "square.and.arrow.up",
                                        color: .secondary,
                                        itemName: "Share the app")
                    }
                    .buttonStyle(.plain)

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
