//
//  ColorSwatchPicker.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/10/2026.
//

import SwiftUI

/// An adaptive grid of color swatches, one of which can be selected.
///
/// Each entry in `colors` is the name of a color asset. Tapping a swatch selects it and
/// shows a checkmark over it; a `nil` selection shows no checkmark.
struct ColorSwatchPicker: View {
    /// The names of the color assets to offer.
    let colors: [String]

    /// The corner radius of each swatch.
    var cornerRadius: CGFloat = 11

    /// The name of the selected color, or `nil` when none is selected.
    @Binding var selection: String?

    #if os(iOS)
    private let columns = [
        GridItem(.adaptive(minimum: 44))
    ]
    #else
    private let columns = [
        GridItem(.adaptive(minimum: 33))
    ]
    #endif

    init(colors: [String], cornerRadius: CGFloat = 11, selection: Binding<String?>) {
        self.colors = colors
        self.cornerRadius = cornerRadius
        self._selection = selection
    }

    /// Creates a picker for a selection that always has a value, such as a Cabinet category's color.
    init(colors: [String], cornerRadius: CGFloat = 11, selection: Binding<String>) {
        self.init(
            colors: colors,
            cornerRadius: cornerRadius,
            selection: Binding<String?>(
                get: { selection.wrappedValue },
                set: { newValue in
                    if let newValue {
                        selection.wrappedValue = newValue
                    }
                }
            )
        )
    }

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(colors, id: \.self) { color in
                swatch(for: color)
            }
        }
    }

    private func swatch(for item: String) -> some View {
        Button {
            selection = item
        } label: {
            ZStack {
                Color(item)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))

                if item == selection {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.white)
                        .font(.title)
                        .symbolEffect(.bounce.down, value: selection)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item) color")
        .accessibilityValue(item == selection ? "Selected" : "Not selected")
        .accessibilityHint("Selects this color.")
        .accessibilityAddTraits(item == selection ? .isSelected : [])
    }
}
