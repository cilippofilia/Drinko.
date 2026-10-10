//
//  CrossPromoBannerView.swift
//  DrinkoPro
//

import PrivateAds
import SwiftUI

/// A persistent ambient banner ad for Filippo Cilia's other apps, refreshed each time this view
/// appears. Pinned to the bottom of the Learn, Cabinet, Cocktails, Tools, and Settings tabs via
/// `.crossPromoBanner()`.
struct CrossPromoBannerView: View {
    /// The width in points of the widest iPhone screen (Pro Max).
    static let maxWidth: CGFloat = 440

    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var ad: Ad?
    @State private var showRemoveAdsPaywall = false

    var body: some View {
        Group {
            if removeAdsStore.isAdsRemoved == false, let ad {
                AdBannerView(
                    advert: ad,
                    config: .crossPromo,
                    hideDismissButtonAndTimer: true,
                    cornerButton: .init(label: "Remove Ads") {
                        showRemoveAdsPaywall = true
                    }
                )
                .padding()
                // Capped (padding included) at the widest iPhone screen, so the banner is the
                // same size on iPad and Mac as on iPhone instead of stretching across the window.
                .frame(maxWidth: Self.maxWidth)
            }
        }
        .task {
            await refreshAd()
        }
        .sheet(isPresented: $showRemoveAdsPaywall) {
            CrossPromoRemoveAdsInfoView()
                .presentationDetents([.medium])
        }
    }

    private func refreshAd() async {
        guard removeAdsStore.isAdsRemoved == false else { return }
        guard let url = AdConfiguration.crossPromo.adsJSONURL else { return }
        ad = try? await AdStore.fetchRandomAd(
            from: url,
            excludedIDs: AdConfiguration.crossPromo.excludedIDs
        )
    }
}

#Preview {
    CrossPromoBannerView()
        .environment(RemoveAdsStore())
}
