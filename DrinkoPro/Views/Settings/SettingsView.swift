//
//  SettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import MessageUI
import StoreKit
import SwiftUI

struct SettingsView: View {
    static let settingsTag: String? = "Settings"

    @State private var email = "cilia.filippo.dev@gmail.com"
    @State private var showOptions = false
    @State private var reportBugSubject = "Bug Report"
    @State private var reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
    @State private var requestFeatureSubject = "Featuristic idea"
    @State private var requestFeatureBody = ""
    @State private var contactDevSubject = ""
    @State private var contactDevBody = ""
    // Check if this link works once the app is live
    @State private var drinkoURL = URL(string: "https://apps.apple.com/gb/app/drinko-cocktail-recipes-app/id6449893371")
    @State private var rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/drinko-cocktail-recipes-app/id6449893371?action=write-review")

    @State private var twitterDevURL = URL(string: "https://twitter.com/fcilia_dev/")

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("App Preferences")) {
                    // MARK: LANGUAGE
                    HStack {
                        SettingsRowView(icon: "character.bubble",
                                        color: .secondary,
                                        itemName: "Language")
                        Spacer()

                        Text(Bundle.main.preferredLocalizations.first!.uppercased())
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }

                // find right term to use
                Section(header: Text("Contacts")) {
                    // MARK: CONTACT THE DEV OPTIONS
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
                            guard let url = URL(string: "mailto:\(email)?subject=\(requestFeatureSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(requestFeatureBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                            UIApplication.shared.open(url)
                        }

                        Button("Other Enquiry") {
                            guard let url = URL(string: "mailto:\(email)?subject=\(contactDevSubject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(contactDevBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }

                            UIApplication.shared.open(url)
                        }
                    }

                    // MARK: FOLLOW ON TWITTER
                    Button(action: {
                        if UIApplication.shared.canOpenURL(twitterDevURL!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(twitterDevURL!,
                                                          options: [:],
                                                          completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(twitterDevURL!)
                            }
                        } else {
                            //redirect to safari because the user doesn't have Instagram
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(twitterDevURL!,
                                                          options: [:],
                                                          completionHandler: nil)
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

                    // MARK: RATE THE APP
                    Button(action: {
                        UIApplication.shared.open(rateURL!,
                                                  options: [:],
                                                  completionHandler: nil)
                    }) {
                        SettingsRowView(icon: "star",
                                        color: .yellow,
                                        itemName: "Rate the app")
                    }
                    .buttonStyle(.plain)
                }

                Section(header: Text("Info"), footer: Text("This app was made with ❤️ by Filippo Cilia 🇮🇹,\na solo iOS app developer.")) {
                    // MARK: READ ME
                    NavigationLink(destination: ReadMeView()) {
                        SettingsRowView(icon: "r.circle",
                                        color: .secondary,
                                        itemName: "Read me")
                    }

                    // MARK: SHARE APP
                    ShareLink(item: drinkoURL!) {
                        SettingsRowView(icon: "square.and.arrow.up",
                                        color: .secondary,
                                        itemName: "Share the app")
                    }
                    .buttonStyle(.plain)

                    // MARK: APP VERSION
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

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
