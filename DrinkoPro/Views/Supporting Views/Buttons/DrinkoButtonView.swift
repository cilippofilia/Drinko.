//
//  DrinkoButton.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI

struct DrinkoButtonView: View {
    typealias ActionHandler = () -> Void

    let title: LocalizedStringKey?
    let icon: String?
    let background: Color
    let foreground: Color
    let handler: ActionHandler

    private let cornerRadius: CGFloat = 10

    internal init(title: LocalizedStringKey?,
                  icon: String?,
                  background: Color = .blue,
                  foreground: Color = .white,
                  handler: @escaping DrinkoButtonView.ActionHandler) {
        self.title = title
        self.icon = icon
        self.background = background
        self.foreground = foreground
        self.handler = handler
    }

    var body: some View {
        Button(action: handler) {
            HStack {
                if icon != nil {
                    Image(systemName: icon!)
                }
                if title != nil {
                    Text(title!)
                        .bold()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .foregroundColor(foreground)
        .background(background)
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}

#if DEBUG
struct DrinkoButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoButtonView(title: "Test button", icon: nil, handler: { })
    }
}
#endif
