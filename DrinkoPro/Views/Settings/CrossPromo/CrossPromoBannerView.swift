//
//  CrossPromoBannerView.swift
//  DrinkoPro
//

import Billboard
import SwiftUI

/// A persistent ambient banner ad for Filippo Cilia's other apps, refreshed each time this view
/// appears. Pinned to the bottom of the Settings tab.
struct CrossPromoBannerView: View {
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var ad: BillboardAd?
    @State private var showRemoveAdsPaywall = false

    var body: some View {
        Group {
            if removeAdsStore.isAdsRemoved == false, let ad {
                BillboardBannerView(advert: ad, config: .crossPromo, hideDismissButtonAndTimer: true)
                    .overlay(alignment: .topTrailing) {
                        Button("Remove Ads", systemImage: "xmark") {
                            showRemoveAdsPaywall = true
                        }
                        .labelStyle(.iconOnly)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.black.opacity(0.45), in: .circle)
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                    .padding()
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
        guard let url = BillboardConfiguration.crossPromo.adsJSONURL else { return }
        ad = try? await BillboardViewModel.fetchRandomAd(
            from: url,
            excludedIDs: BillboardConfiguration.crossPromo.excludedIDs
        )
    }
}

#Preview {
    CrossPromoBannerView()
        .environment(RemoveAdsStore())
}
