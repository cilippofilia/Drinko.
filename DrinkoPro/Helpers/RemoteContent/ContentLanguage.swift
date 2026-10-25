//
//  ContentLanguage.swift
//  DrinkoPro
//

import Foundation

/// Maps the user's preferred languages onto the languages the remote content is available in.
enum ContentLanguage {
    static let supported: Set<String> = ["en", "de", "es", "fr", "it"]

    /// Uses the first preferred language without its region, or `"en"` when it isn't supported.
    static func resolve(_ preferred: [String]) -> String {
        guard let first = preferred.first else { return "en" }
        let code = first.lowercased()
            .prefix { $0 != "-" && $0 != "_" }
        let language = String(code)
        return supported.contains(language) ? language : "en"
    }
}
