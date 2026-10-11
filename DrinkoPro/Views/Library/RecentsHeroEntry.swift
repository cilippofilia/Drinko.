//
//  RecentsHeroEntry.swift
//  DrinkoPro
//

/// What the recents carousel needs from one item, worked out once when the items change
/// instead of on every frame of a swipe.
struct RecentsHeroEntry: Hashable {
    let model: LibraryCardModel
    let backdrop: RecentsHeroLayout.Backdrop

    init(model: LibraryCardModel) {
        self.model = model
        backdrop = RecentsHeroLayout.backdrop(for: model.image)
    }
}
