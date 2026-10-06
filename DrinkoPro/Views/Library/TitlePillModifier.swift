//
//  TitlePillModifier.swift
//  DrinkoPro
//

import SwiftUI

/// Sets a title on Liquid Glass over artwork, falling back to a rounded material backdrop before
/// iOS 26 and macOS 26.
///
/// The glass is a `ConcentricRectangle`, so its corners follow the nearest `containerShape`:
/// the card or header it sits in must declare one.
struct TitlePillModifier: ViewModifier {
    /// The space above and below the title inside its pill.
    @ScaledMetric private var verticalPadding: CGFloat = 8
    /// The smallest corner radius the pill keeps when it sits too far in from the
    /// container's corner to follow it.
    @ScaledMetric private var minimumCornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        let padded = content
            .padding(.horizontal)
            .padding(.vertical, verticalPadding)

        if #available(iOS 26, macOS 26, *) {
            padded.glassEffect(
                .regular,
                in: ConcentricRectangle(corners: .concentric(minimum: .fixed(minimumCornerRadius)), isUniform: true)
            )
        } else {
            padded.background(.regularMaterial, in: .rect(cornerRadius: minimumCornerRadius))
        }
    }
}

extension View {
    /// Sets this title on Liquid Glass whose corners follow the enclosing `containerShape`.
    func titlePill() -> some View {
        modifier(TitlePillModifier())
    }
}
