//
//  SettingsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import FirebaseAuth
import MessageUI
import StoreKit
import SwiftUI

struct SettingsView: View {
    static let settingsTag: String? = "Settings"

    @EnvironmentObject private var factory: ViewModelFactory

    @State private var email = "cilia.filippo.dev@gmail.com"
    @State private var showOptions = false
    @State private var reportBugSubject = "Bug Report"
    @State private var reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
    @State private var requestFeatureSubject = "Featuristic idea"
    @State private var requestFeatureBody = ""
    @State private var contactDevSubject = ""
    @State private var contactDevBody = ""
    @State private var lovelyText = "This app was made with ❤️ by Filippo Cilia 🇮🇹"

    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
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

                NavigationLink(destination: PostsList(viewModel: factory.makePostsViewModel(filter: .favorites))) {
                    SettingsRowView(icon: "heart.fill", color: .red, itemName: "Liked posts")
                }
            }

            // find right term to use
            Section(header: Text("Contacts")) {
                Button(action: {
                    showOptions = true
                }) {
                    SettingsRowView(icon: "envelope",
                                    color: .blue,
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

                Button(action: {
                    UIApplication.shared.open(rateURL!,
                                              options: [:],
                                              completionHandler: nil)
                }) {
                    SettingsRowView(icon: "star.fill",
                                    color: .yellow,
                                    itemName: "Rate the app")
                }
                .buttonStyle(.plain)

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
                        //redirect to safari because the user doesn't have Twitter
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(twitterDevURL!,
                                                      options: [:],
                                                      completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(twitterDevURL!)
                        }
                    }
                }) {
                    SettingsRowView(icon: "bird.fill",
                                    color: .blue,
                                    itemName: "Twitter")
                }
                .buttonStyle(.plain)
            }

            Section(header: Text("Info"), footer: Text(lovelyText)) {
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

            Section {
                Button("Sign Out", action: {
                    try! Auth.auth().signOut()
                })
                .foregroundColor(.red)
            }
        }
        .navigationBarTitle("Settings")
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
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
