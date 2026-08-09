//
//  CrossPromoRemoveAdsInfoView.swift
//  DrinkoPro
//

import StoreKit
import SwiftUI

/// PrivateAds's interstitial always offers a "Remove Ads" button that opens a paywall. This is
/// that paywall: a one-time, non-consumable purchase that silences the cross-promo ads for good.
/// `ProductView`'s `.compact` style supplies the purchase button sized for exactly one product;
/// Restore Purchase and the legal links are pinned in a bottom safe-area inset, mirroring the
/// paywall pattern used across Filippo Cilia's other apps.
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

                Spacer()
            }
            .padding(.top, 32)
            .safeAreaInset(edge: .bottom) {
                RemoveAdsLegalFooterView(isRestoring: isRestoring, onRestore: restore)
                    .padding()
            }
            .onInAppPurchaseCompletion { _, result in
                if case .success(.success(_)) = result {
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
