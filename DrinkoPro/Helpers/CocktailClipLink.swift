//
//  CocktailClipLink.swift
//  DrinkoPro
//

import Foundation

/// Builds the link shared with a cocktail's recipe card, and reads a cocktail ID back out of
/// every link format Drinko understands, for both the App Clip and the full app.
enum CocktailClipLink {
    /// The App Clip's bundle ID, which Apple's default App Clip link names in its `p` parameter.
    static let appClipBundleID = "me.cilia.filippo.DrinkoPro.Clip"

    private static let appClipHost = "appclip.apple.com"
    private static let ownDomainHost = "drinko.app"
    private static let cocktailQueryItem = "cocktail"
    private static let queryValueAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&+=?"))

    /// Apple's default App Clip link for `cocktailID`. It works without a website: in Messages it
    /// shows as an App Clip card, and it opens the full app instead when that's installed.
    static func url(for cocktailID: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = appClipHost
        components.path = "/id"
        // `queryItems` leaves `&`, `+`, `=` and `?` unencoded in values, which would break IDs
        // containing them, so the values are encoded here instead.
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "p", value: appClipBundleID),
            URLQueryItem(name: cocktailQueryItem, value: cocktailID.addingPercentEncoding(withAllowedCharacters: queryValueAllowed))
        ]
        return components.url ?? URL(filePath: "/")
    }

    /// The cocktail ID in `url`, or `nil` if it isn't a Drinko cocktail link. Accepts the default
    /// App Clip link, `https://drinko.app/c/<id>` and `drinko://cocktail/<id>`.
    static func cocktailID(from url: URL) -> String? {
        let id: String?
        switch (url.scheme, url.host()) {
        case ("https", appClipHost):
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            guard items.first(where: { $0.name == "p" })?.value == appClipBundleID else { return nil }
            id = items.first { $0.name == cocktailQueryItem }?.value
        case ("https", ownDomainHost):
            let parts = pathParts(of: url)
            guard parts.first == "c" else { return nil }
            id = parts.dropFirst().first
        case ("drinko", "cocktail"):
            id = pathParts(of: url).first
        default:
            id = nil
        }
        guard let id, !id.isEmpty else { return nil }
        return id
    }

    private static func pathParts(of url: URL) -> [String] {
        url.pathComponents.filter { $0 != "/" }
    }
}
