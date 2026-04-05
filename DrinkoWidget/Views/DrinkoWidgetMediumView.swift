//
//  DrinkoWidgetMediumView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 4/5/26.
//

import SwiftUI
import WidgetKit

struct DrinkoWidgetMediumView: View {
    let cocktail: WidgetCocktail
    let imageData: Data?

    var body: some View {
        HStack(spacing: 0) {
            Color.red
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Color.yellow
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        HStack {
//            WidgetRenderedImage(imageData: imageData)
//                .frame(maxWidth: .infinity, alignment: .bottom)
//                .scaleEffect(2)
//                .offset(y: 50)
//
//            VStack(alignment: .leading) {
//                Text(cocktail.name)
//                    .bold()
//                    .foregroundStyle(.black)
//                    .multilineTextAlignment(.leading)
//                    .lineLimit(3)
//            }
//        }
    }
}

struct DrinkoWidgetMediumView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkoWidgetMediumView(
            cocktail: DrinkoWidgetCatalog.nullCocktail,
            imageData: nil
        )
        .containerBackground(.white, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
