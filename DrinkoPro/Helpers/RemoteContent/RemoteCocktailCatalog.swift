//
//  RemoteCocktailCatalog.swift
//  DrinkoPro
//

import Foundation

/// Builds a cocktail catalog from GitHub for the App Clip, which bundles only a subset of the drinks.
enum RemoteCocktailCatalog {
    /// A catalog from the loader's content, or nil unless the cocktails are valid. Shots, history and
    /// procedures fall back to the bundled copies, since the catalog is still useful without them.
    static func load(loader: ReadOnlyContentLoader, bundle: Bundle = .main) async -> BundledCocktailCatalog? {
        async let cocktailsData = loader.validData(for: .cocktails)
        async let shotsData = loader.validData(for: .shots)
        async let historyData = loader.validData(for: .history)
        async let procedureData = loader.validData(for: .procedure)

        let remoteCocktails = await cocktailsData.flatMap { try? JSONDecoder().decode([Cocktail].self, from: $0) }
        guard let cocktails = remoteCocktails else { return nil }
        let shots = await shotsData.flatMap { try? JSONDecoder().decode([Cocktail].self, from: $0) }
            ?? bundle.decode([Cocktail].self, from: ContentFile.shots.bundleFileName)
        let histories = await historyData.flatMap { try? JSONDecoder().decode([History].self, from: $0) }
            ?? bundle.decode([History].self, from: ContentFile.history.bundleFileName)
        let procedures = await procedureData.flatMap { try? JSONDecoder().decode([Procedure].self, from: $0) }
            ?? bundle.decode([Procedure].self, from: ContentFile.procedure.bundleFileName)

        return BundledCocktailCatalog(cocktails: cocktails + shots, histories: histories, procedures: procedures)
    }

    /// Fetches with the extension timeout and no cache, since only the app writes the cache.
    static func live() async -> BundledCocktailCatalog? {
        await load(loader: ReadOnlyContentLoader(
            cache: nil,
            fetcher: URLSessionContentFetcher(timeout: URLSessionContentFetcher.extensionTimeout),
            language: ContentLanguage.resolve(Bundle.main.preferredLocalizations)
        ))
    }
}
