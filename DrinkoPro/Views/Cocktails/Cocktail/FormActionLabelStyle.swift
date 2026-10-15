//
//  FormActionLabelStyle.swift
//  DrinkoPro
//

import SwiftUI

/// An action row in a form: the title in the primary text color, so the rows read like the rest
/// of the form, with only the icon colored to mark it as tappable. Destructive rows keep the
/// system style, all in red.
struct FormActionLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        Label {
            // `Color.primary`, not the `.primary` style: inside a button that's the button's own
            // tint, while the color is always the text color.
            configuration.title
                .foregroundStyle(Color.primary)
        } icon: {
            configuration.icon
                // The accent color by name rather than `.tint`, so a row that sets its tint to
                // the text color (a menu, which tints its whole label) keeps a colored icon.
                .foregroundStyle(Color.accentColor)
        }
    }
}

extension LabelStyle where Self == FormActionLabelStyle {
    /// A form action row with a tinted icon and primary-colored title.
    static var formAction: FormActionLabelStyle {
        FormActionLabelStyle()
    }
}

#if DEBUG
#Preview {
    Form {
        Button("Add Ingredient", systemImage: "plus") { }
            .labelStyle(.formAction)
    }
}
#endif
