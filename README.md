# Drinko: Cocktail recipes, bartending lessons, and a home bar cabinet

## About

Drinko is a SwiftUI app for learning bartending, browsing classic cocktails, and keeping track of the ingredients you already have at home.

It ships as one project with four products:

- **Drinko for iPhone and iPad**, with five tabs: Learn, Cabinet, Cocktails, Tools, and Settings.
- **Drinko for Mac**, which has its own sidebar-driven layout.
- **A home screen widget** that shows a daily cocktail pick.
- **An App Clip** that opens a shared cocktail recipe without installing the app.

The lessons and the cocktail library are downloaded from GitHub and cached on the device. A bundled copy covers the first launch and offline use.

## Features

### Learn

- Topic-based lessons for bartending basics, bar prep, spirits, liqueurs, advanced techniques, and syrups.
- A reference books section.
- Search across lessons and books.
- A Recents hero that brings back what you viewed last, plus a grid/list layout toggle.

### Cocktails

- About 150 cocktails and 40 shots, each with ingredients, method, history, procedure, and related cocktails.
- Search using localized matching.
- Sorting by name, glass, or ice style.
- Filters for all drinks, cocktails only, shots only, favorites, and drinks you created.
- Custom cocktails with your own photo. The photo can be turned into a sticker and given a tint colour.
- Ingredient amounts in ounces or millilitres.
- Share a cocktail as a rendered recipe card. The card carries an App Clip link, and the share message varies and is localized.

### Cabinet

- Ingredient categories with products in each, and favourite products.
- Stored with SwiftData and synced through CloudKit.

### Tools

- ABV calculator.
- Super juice calculator.

### Settings

- Contact flows for bug reports, feature requests, and general feedback.
- An in-app rating shortcut.
- A widget tutorial, shown once automatically after a few launches.
- An in-app README/about screen.
- A Remove Ads in-app purchase that hides the cross-promo banner.

### Widget

- Small and medium sizes.
- Configurable through Edit Widget: choose all drinks, cocktails only, shots only, or favorites, and whether the medium size shows ingredients.
- Uses the cocktail stickers. Content comes from the shared cache first, then GitHub, then the bundle.

### App Clip

- Opens `https://drinko.app/c/<id>` and `drinko://cocktail/<id>` links, plus Apple's default App Clip links.
- Cocktails it doesn't bundle are fetched from the remote catalog.

### Across devices

- Favorites, recents, and preferences sync through iCloud key-value storage.
- Localized in English, French, German, Italian, and Spanish.
- On regular-width iPad and iPhone layouts, the tab bar becomes a sidebar with rows for sections, categories, filters, and tools.

## Tech Stack

- SwiftUI for the UI.
- SwiftData with CloudKit for the Cabinet and custom cocktails.
- `NSUbiquitousKeyValueStore` for favorites, recents, and preferences.
- WidgetKit and App Intents for the configurable widget.
- App Clips.
- StoreKit for review prompts and the Remove Ads purchase. `Drinko.storekit` provides local testing.
- [PrivateAds](https://github.com/cilippofilia/PrivateAds) (Swift Package) for the cross-promo banner.
- Swift Testing for unit tests, with a few older XCTest suites.
- SwiftLint, configured in `.swiftlint.yml`.

## Remote Content

Learn and Cocktails content is fetched from [`cilippofilia/drinko-learn`](https://github.com/cilippofilia/drinko-learn), which is the source of truth for that content:

- The app sends conditional GETs and applies a refresh only if every file downloads.
- Downloaded files are cached for 7 days in the shared App Group container, so the widget and App Clip read the same cache.
- If no cache exists, the app falls back to the JSON in `DrinkoPro/Localization`.
- Debug builds show a Settings footer saying whether content came from the bundle, the cache, or a fresh download.

Images are served from separate repositories: `drinko-learn-pics`, `drinko-cocktail-pics`, and `Drinko-stickers`.

## Project Structure

```text
Drinko/
├── DrinkoPro/            # iOS app and shared source
│   ├── Assets/
│   ├── Helpers/          # Navigation, sharing, stickers, CloudSync/, RemoteContent/
│   ├── Localization/     # String catalogs and bundled JSON content
│   ├── Models/           # Cabinet, Cocktails, Learn
│   └── Views/            # Cabinet, Cocktails, Learn, Library, Settings, Tools
├── DrinkoMac/            # macOS-specific views and flows
├── DrinkoWidget/         # Cocktail-of-the-day widget extension
├── DrinkoClip/           # App Clip for shared cocktail links
├── DrinkoProTests/       # Unit tests and JSON fixtures
├── metadata/             # Canonical App Store metadata per version and locale
├── app-store-assets/     # App Store artwork sources
├── drinko-press-kit/     # Press kit
├── docs/                 # ASO notes
├── Drinko.storekit       # StoreKit configuration for local testing
└── DrinkoPro.xcodeproj
```

## Requirements

- Xcode with the iOS 18 and macOS 15 SDKs or newer.
- iOS 18.0+ for the app, widget, and App Clip.
- macOS 15.6+ for the Mac app.

## Getting Started

1. Clone the repository:

```bash
git clone <your-fork-or-repo-url>
cd Drinko
```

2. Open the project in Xcode:

```bash
open DrinkoPro.xcodeproj
```

3. Pick a scheme:
   - `DrinkoPro`: iOS app
   - `DrinkoDesktop`: Mac app
   - `DrinkoWidget`: widget extension
   - `DrinkoClip`: App Clip
   - `DrinkoProTests`: unit tests

4. Build and run.

### Signing

The project uses capabilities that are tied to the original team. To run it on your own team, set up your own equivalents of:

- iCloud with CloudKit and key-value storage
- the App Group shared by the app, widget, and App Clip
- associated App Clip identifiers

## Tests

Unit tests live in `DrinkoProTests`. Most use Swift Testing, and a few older suites still use XCTest. They cover:

- remote content: fetching, caching, cache migration, the refresher, snapshots, and the widget/App Clip loaders
- iCloud key-value sync and merging
- navigation, tab restoration, and Cabinet selection
- cocktail and lesson loading, filtering, and linking
- App Clip links, share messages, and share items
- stickers, user photos, and tint colours
- widget catalog and sticker selection
- the ABV calculator and oz/ml conversion

Run them with the `DrinkoProTests` scheme or Xcode's test action.

## Documentation

- [`ROADMAP.md`](ROADMAP.md): planned and shipped enhancements.
- [`metadata/`](metadata): the App Store listing (name, subtitle, description, keywords, What's New) for each version and locale.
- [`docs/app-store-aso-sheet.md`](docs/app-store-aso-sheet.md): keyword notes and the screenshot storyboard.

## Author

Filippo Cilia

- X: [@fcilia_dev](https://x.com/fcilia_dev)
- Instagram: [@cilippofilia](https://www.instagram.com/cilippofilia)
- App Store: [Drinko](https://apps.apple.com/gb/app/drinko/id6449893371)

## License

This project is proprietary software. All rights reserved.
