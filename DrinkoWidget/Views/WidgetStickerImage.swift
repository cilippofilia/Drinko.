//
//  WidgetStickerImage.swift
//  DrinkoWidget
//

import SwiftUI
import WidgetKit

/// The cocktail's sticker, or a glass symbol when it couldn't be downloaded.
struct WidgetStickerImage: View {
    let stickerData: Data?

    var body: some View {
        if let stickerData, let uiImage = UIImage(data: stickerData) {
            Image(uiImage: uiImage)
                .resizable()
                // Keeps the sticker's own colors on tinted home screens instead of
                // flattening it into a silhouette.
                .widgetAccentedRenderingMode(.fullColor)
                .scaledToFit()
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        } else {
            // Takes a sticker's tall shape so the layout around it doesn't shift.
            Color.clear
                .aspectRatio(0.5, contentMode: .fit)
                .overlay {
                    Image(systemName: "wineglass")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black.opacity(0.25))
                        .padding(8)
                }
        }
    }
}
