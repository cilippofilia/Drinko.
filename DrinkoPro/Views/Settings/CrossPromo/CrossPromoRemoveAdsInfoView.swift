//
//  CrossPromoRemoveAdsInfoView.swift
//  DrinkoPro
//

import StoreKit
import SwiftUI

/// The paywall behind PrivateAds's "Remove Ads" button: a one-time purchase that silences the
/// cross-promo ads for good.
struct CrossPromoRemoveAdsInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if removeAdsStore.isAdsRemoved {
            ContentUnavailableView {
                Label("Ads Removed", systemImage: "checkmark.circle.fill")
            } description: {
                Text("Thanks for your support — you won't see these cross-promo ads again.")
            }
        } else {
            // Scrollable so the description wraps to its full height in the `.medium` detent instead of
            // being truncated.
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        RemoveAdsBadge()
                            .clipShape(.circle)

                        Text("Remove Ads")
                            .font(.title2)
                            .bold()

                        Text("These occasional promos are for my other apps. Remove them for good with a small one-time purchase.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ProductView(id: RemoveAdsStore.removeAdsProductID)
                        .productViewStyle(.compact)
                        .padding(.horizontal)

                    if let restoreError = removeAdsStore.restoreError {
                        Text(restoreError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 32)
                .frame(maxWidth: readableContentWidth)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom) {
                RemoveAdsLegalFooterView(isRestoring: isRestoring, onRestore: restore)
                    .padding()
            }
            .onInAppPurchaseCompletion { _, result in
                if case .success(.success) = result {
                    dismiss()
                }
            }
        }
    }

    private func restore() {
        isRestoring = true
        Task {
            defer { isRestoring = false }
            await removeAdsStore.restore()
        }
    }
}

#Preview {
    CrossPromoRemoveAdsInfoView()
        .environment(RemoveAdsStore())
}
