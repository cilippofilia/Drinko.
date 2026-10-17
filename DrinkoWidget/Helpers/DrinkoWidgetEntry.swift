//
//  DrinkoWidgetEntry.swift
//  DrinkoWidget
//
//  Created by Filippo Cilia on 04/04/2026.
//

import WidgetKit

struct DrinkoWidgetEntry: TimelineEntry {
    let date: Date
    let cocktail: WidgetCocktail
    let stickerData: Data?
    let showsIngredients: Bool

    /// Worked out once per entry so the views don't rank ingredients on every render.
    let mainSpirit: MainSpirit?

    var deepLinkURL: URL? {
        URL(string: "drinko://cocktail/\(cocktail.id)")
    }
}

#if DEBUG
extension DrinkoWidgetEntry {
    /// An Aperol Spritz for previews, with its real sticker when it can be downloaded.
    static func preview(showsIngredients: Bool = true) -> DrinkoWidgetEntry {
        preview(
            WidgetCocktail(
                id: "aperol-spritz", name: "Aperol Spritz", method: "build", glass: "wine",
                garnish: "orange slice", ice: "cubed", extra: "-",
                ingredients: [
                    .init(name: "Prosecco", quantity: 3, unit: "oz."),
                    .init(name: "Aperol", quantity: 2, unit: "oz."),
                    .init(name: "Soda water", quantity: 1, unit: "oz.")
                ]
            ),
            showsIngredients: showsIngredients
        )
    }

    /// A drink with a long name and many ingredients, to check wrapping.
    static let longNamePreview = preview(
        WidgetCocktail(
            id: "philadelphia-fish-house-punch", name: "Philadelphia Fish House Punch",
            method: "build", glass: "punch cup", garnish: "lemon wheel", ice: "block", extra: "-",
            ingredients: [
                .init(name: "Cognac", quantity: 1, unit: "oz."),
                .init(name: "Jamaican rum", quantity: 1, unit: "oz."),
                .init(name: "Peach brandy", quantity: 0.5, unit: "oz."),
                .init(name: "Lemon juice", quantity: 1, unit: "oz."),
                .init(name: "Sugar syrup", quantity: 0.75, unit: "oz."),
                .init(name: "Black tea", quantity: 2, unit: "oz.")
            ]
        ),
        showsIngredients: true
    )

    /// A B-52, to check the "Shot of the Day" header.
    static let shotPreview = preview(
        WidgetCocktail(
            id: "b-52", name: "B-52", method: "build & layer", glass: "shot",
            garnish: "-", ice: "-", extra: "-",
            ingredients: [
                .init(name: "Kahlua", quantity: 0.3, unit: "oz."),
                .init(name: "Bailey's", quantity: 0.3, unit: "oz."),
                .init(name: "Grand Marnier", quantity: 0.3, unit: "oz.")
            ]
        ),
        showsIngredients: true
    )

    private static func preview(_ cocktail: WidgetCocktail, showsIngredients: Bool) -> DrinkoWidgetEntry {
        DrinkoWidgetEntry(
            date: .now,
            cocktail: cocktail,
            stickerData: DrinkoWidgetImageStore.stickerData(for: cocktail),
            showsIngredients: showsIngredients,
            mainSpirit: cocktail.mainSpirit
        )
    }
}
#endif
