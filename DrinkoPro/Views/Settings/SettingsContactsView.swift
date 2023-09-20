//
//  SettingsContactsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import MessageUI
import SwiftUI

struct SettingsContactsView: View {
    @State private var showOptions = false
    @State private var email = "cilia.filippo.dev@gmail.com"
    @State private var reportBugSubject = "Bug Report"
    @State private var reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
    @State private var requestFeatureSubject = "Featuristic idea"
    @State private var requestFeatureBody = ""
    @State private var contactDevSubject = ""
    @State private var contactDevBody = ""

    var body: some View {
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
                HStack {
                    Image("x")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(.horizontal, 8)

                    Text("X - Twitter")
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SettingsContactsView()
}
