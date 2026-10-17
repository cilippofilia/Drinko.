//
//  PolaroidFrame.swift
//  DrinkoPro
//

import SwiftUI

/// The paper is the same in both appearances, like a real print, so the caption is always dark.
struct PolaroidFrame<Photo: View, Caption: View>: View {
    @ViewBuilder let photo: Photo
    @ViewBuilder let caption: Caption

    static var paper: Color {
        Color(red: 0.97, green: 0.96, blue: 0.94)
    }

    @ScaledMetric private var border: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: border) {
            photo
                .environment(\.stickerBackdropCornerRadius, polaroidPhotoCornerRadius)
                .clipShape(.rect(cornerRadius: polaroidPhotoCornerRadius))
                // A faint edge where the photo meets the paper, so pale photos don't bleed into it.
                .overlay {
                    RoundedRectangle(cornerRadius: polaroidPhotoCornerRadius)
                        .strokeBorder(.black.opacity(0.06), lineWidth: 1)
                }

            caption
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, border / 2)
        }
        .padding(border)
        .background(Self.paper, in: .rect(cornerRadius: polaroidCornerRadius))
        .environment(\.colorScheme, .light)
    }
}

#if DEBUG
#Preview {
    PolaroidFrame {
        Color.orange
            .aspectRatio(1, contentMode: .fit)
    } caption: {
        Text(verbatim: "Negroni")
            .font(.headline)
    }
    .frame(width: 180)
    .padding()
    .background(.black)
}
#endif
