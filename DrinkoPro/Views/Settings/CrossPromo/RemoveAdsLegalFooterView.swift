//
//  RemoveAdsLegalFooterView.swift
//  DrinkoPro
//

import SwiftUI

/// The Restore Purchase / Terms of Use / Privacy Policy row, pinned to the bottom of
/// `CrossPromoRemoveAdsInfoView` via `.safeAreaInset(edge: .bottom)` so it stays on screen
/// rather than scrolling away with the rest of the paywall.
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
