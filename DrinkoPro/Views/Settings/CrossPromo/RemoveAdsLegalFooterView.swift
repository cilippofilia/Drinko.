//
//  RemoveAdsLegalFooterView.swift
//  DrinkoPro
//

import SwiftUI

struct RemoveAdsLegalFooterView: View {
    @Environment(\.openURL) private var openURL

    let isRestoring: Bool
    let onRestore: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if isRestoring {
                ProgressView()
                    .controlSize(.mini)
            } else {
                Button("Restore Purchase", action: onRestore)
            }

            Text("•")
                .foregroundStyle(.tertiary)

            Button("Terms of Use") { openURL(RemoveAdsLegalLinks.termsOfUse) }

            Text("•")
                .foregroundStyle(.tertiary)

            Button("Privacy Policy") { openURL(RemoveAdsLegalLinks.privacyPolicy) }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        Spacer()
        RemoveAdsLegalFooterView(isRestoring: false, onRestore: {})
    }
}
