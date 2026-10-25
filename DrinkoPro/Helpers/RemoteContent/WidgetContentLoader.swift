//
//  WidgetContentLoader.swift
//  DrinkoPro
//

import Foundation

/// Loads the widget's drinks from the app's shared cache, then GitHub, then the copy in the bundle.
nonisolated struct WidgetContentLoader: Sendable {
    private let loader: ReadOnlyContentLoader
    private let bundle: Bundle

    init(loader: ReadOnlyContentLoader, bundle: Bundle = .main) {
        self.loader = loader
        self.bundle = bundle
    }

    /// Builds a loader that never touches the network when `allowsNetwork` is false (the widget gallery).
    static func make(
        cache: ContentCache?,
        fetcher: any ContentFetching,
        allowsNetwork: Bool,
        language: String,
        bundle: Bundle = .main
    ) -> WidgetContentLoader {
        WidgetContentLoader(
            loader: ReadOnlyContentLoader(
                cache: cache,
                fetcher: allowsNetwork ? fetcher : nil,
                language: language
            ),
            bundle: bundle
        )
    }

    /// The loader the widget uses: the shared cache, GitHub with the extension timeout, then the bundle.
    static func live(allowsNetwork: Bool) -> WidgetContentLoader {
        make(
            cache: ContentCache.standard,
            fetcher: URLSessionContentFetcher(timeout: URLSessionContentFetcher.extensionTimeout),
            allowsNetwork: allowsNetwork,
            language: ContentLanguage.resolve(Bundle.main.preferredLocalizations)
        )
    }

    /// Resolves both files at the same time, so the worst case stays near one network timeout.
    func drinks() async -> (cocktails: [WidgetCocktail], shots: [WidgetCocktail]) {
        async let cocktails = widgetCocktails(for: .cocktails)
        async let shots = widgetCocktails(for: .shots)
        return await (cocktails, shots)
    }

    private func widgetCocktails(for file: ContentFile) async -> [WidgetCocktail] {
        if let data = await loader.validData(for: file),
           let cocktails = try? JSONDecoder().decode([Cocktail].self, from: data) {
            return cocktails.map(WidgetCocktail.init)
        }
        return bundle.decode([WidgetCocktail].self, from: file.bundleFileName)
    }
}
