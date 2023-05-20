//
//  DrinkoButton.swift
//  Drinko
//
//  Created by Filippo Cilia on 28/04/2023.
//

import SwiftUI

struct DrinkoButtonStyle: View {
    var symbolName: String
    var text: LocalizedStringKey
    var color: Color
    var background: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)

            Text(text)
        }
        .font(.headline.bold())
        .frame(height: 50)
        .frame(maxWidth: screenWidthPlusMargins)
        .foregroundColor(color)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct DrinkoButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoButtonStyle(symbolName: "video", text: "Go to video", color: .white, background: .blue)
    }
}
