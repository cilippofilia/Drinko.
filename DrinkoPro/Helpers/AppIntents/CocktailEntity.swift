import AppIntents
import Foundation

/// A cocktail or shot exposed to Siri, Shortcuts and Spotlight.
/// Built from the app's `Cocktail` model rather than conforming the model itself.
/// Its members are `nonisolated` one by one: marking the whole type would also mark the
/// `@Property` storage, which Swift 6 rejects.
struct CocktailEntity: AppEntity, IndexedEntity {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Cocktail"
    nonisolated static let defaultQuery = CocktailEntityQuery()

    nonisolated let id: String

    @Property(title: "Name")
    var name: String

    nonisolated let isShot: Bool
    nonisolated private let glass: String

    nonisolated init(_ cocktail: Cocktail) {
        glass = cocktail.glass
        // Every bundled shot is served in a shot glass, the same rule the widget uses.
        isShot = cocktail.glass == "shot"
        id = cocktail.id
        name = cocktail.name
    }

    nonisolated var displayRepresentation: DisplayRepresentation {
        // The spoken name drops a trailing year so "Zombie" fits a one-sentence phrase.
        let title = CocktailNameMatcher.spokenName(name)
        var synonyms = [name]
        let stripped = CocktailNameMatcher.punctuationStripped(name)
        if !stripped.isEmpty { synonyms.append(stripped) }
        let unique = synonyms.filter { $0 != title }
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(glass)",
            image: nil,
            synonyms: unique.map { "\($0)" }
        )
    }
}
