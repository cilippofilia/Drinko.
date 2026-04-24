//
//  DrinkoWidgetSmallView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI

struct DrinkoWidgetSmallView: View {
    let cocktail: WidgetCocktail
    let imageData: Data?

    var body: some View {
        ZStack {
            Text(cocktail.name)
                .font(.system(size: 36, weight: .heavy, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.5)
                .frame(maxHeight: .infinity, alignment: .top)

            WidgetRenderedImage(imageData: imageData)
                .scaleEffect(1.25)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}
