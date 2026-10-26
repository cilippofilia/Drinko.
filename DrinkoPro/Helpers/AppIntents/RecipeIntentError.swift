import AppIntents
import Foundation

/// Problems the recipe intents report back to Siri in the user's language.
enum RecipeIntentError: Error, CustomLocalizedStringResourceConvertible {
    case noCocktails

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noCocktails:
            "Drinko has no cocktails yet."
        }
    }
}
