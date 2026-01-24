//
//  SettingsContactsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

#if os(iOS)
import MessageUI
#endif
import SwiftUI

struct SettingsContactsView: View {
    @Environment(\.openURL) private var openURL

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
                                color: .primary,
                                itemName: "Contact the developer")
            }
            .buttonStyle(PlainButtonStyle())
            #if os(iOS)
            .disabled(!MFMailComposeViewController.canSendMail())
            #endif
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
        }
    }
}

private extension SettingsContactsView {
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
            SettingsRowView(
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
    Form {
        SettingsContactsView()
    }
}
#endif
