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
    @State private var reportBugSubject = "Drinko: Bug Report"
    @State private var reportBugBody = "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
    @State private var requestFeatureSubject = "Drinko: Featuristic idea"
    @State private var requestFeatureBody = ""
    @State private var contactDevSubject = "Drinko: Enquiry"
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
    func openMail(subject: String, body: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]

        guard let url = components.url else { return }

        openURL(url)
    }

    var reportBug: some View {
        Button("Report a bug") {
            openMail(subject: reportBugSubject, body: reportBugBody)
        }
    }

    var requestFeature: some View {
        Button("Request a Feature") {
            openMail(subject: requestFeatureSubject, body: requestFeatureBody)
        }
    }

    var otherEnquiry: some View {
        Button("Other Enquiry") {
            openMail(subject: contactDevSubject, body: contactDevBody)
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
