# Drinko: Cocktail recipes, bartending lessons, and a home bar cabinet

## About

Drinko is a SwiftUI app for learning bartending, browsing classic cocktails, and keeping track of the ingredients you already have at home.

The app combines three core workflows in one project:

- Learn bartending techniques, spirits, syrups, and prep fundamentals.
- Browse a built-in cocktail library with search, sorting, favorites, and detailed drink pages.
- Manage a personal cabinet with SwiftData-backed categories and products that can sync through CloudKit.

Drinko also supports custom cocktails, built-in oz/ml conversion, and a macOS target for selected app flows.

## Features

### Learn

- Topic-based lessons for bartending basics, bar prep, spirits, liqueurs, advanced lessons, and syrups.
- Reference books section.
- Built-in calculators for ABV and super juice.
- Search across lessons and books.

### Cocktails

- Built-in library of cocktails and shots loaded from bundled JSON data.
- Search using localized matching.
- Sorting by name, glass, or ice style.
- Filters for all drinks, cocktails only, shots only, favorites, and user-created drinks.
- Detailed cocktail pages with ingredients, method, history, procedure, and related cocktails.
- Create and delete custom cocktails.
- Save favorite cocktails locally.
- Convert ingredient measurements between ounces and milliliters.

### Cabinet

- Create ingredient categories and add products to each category.
- Mark products as favorites.
- Persist cabinet data with SwiftData.
- CloudKit-backed model configuration for syncing supported data across devices.

### Settings

- Contact flows for bug reports, feature requests, and general feedback.
- In-app rating shortcut.
- Localized app copy and built-in README/about screen.

## Tech Stack

- SwiftUI for the UI
- SwiftData for local persistence
- CloudKit for sync-backed model storage
- StoreKit for review prompts
- MessageUI for email-based feedback on iOS
- Swift Testing and XCTest for unit coverage

## Project Structure

```text
Drinko/
├── DrinkoPro/          # Main app target and shared source
│   ├── Assets/
│   ├── Helpers/
│   ├── Localization/
│   ├── Models/
│   └── Views/
├── DrinkoMac/          # macOS-specific views and flows
├── DrinkoProTests/     # Unit tests
├── docs/               # App Store and product documentation
└── DrinkoPro.xcodeproj
```

The main app surface is organized around four tabs: `Learn`, `Cocktails`, `Cabinet`, and `Settings`.

## Requirements

- Xcode with iOS 18 and macOS 15 SDK support
- iOS 18+
- macOS 15+

The checked-in Xcode project currently uses iOS 18 deployment settings for the app target and macOS 15 deployment settings for the Mac target.

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

3. Select the `DrinkoPro` scheme for iOS, or the Mac target if you want to run the desktop build.

4. Build and run from Xcode.

## Development Notes

- The cocktail library, histories, procedures, lessons, books, and other reference content are bundled as JSON resources.
- User-created cocktails are stored through SwiftData models.
- Favorites are stored locally in `UserDefaults`.
- CloudKit capability is enabled in the project entitlements, so running sync features on your own team may require your own signing setup.

## Tests

Unit tests live in `DrinkoProTests` and currently cover:

- cocktail data loading, filtering, grouping, and linking behavior
- lesson loading and topic organization
- unit conversion logic for oz/ml ingredient amounts

Run them from Xcode’s test action for the active scheme.

## Documentation

App Store metadata, localized copy, and screenshot messaging live in [`docs/app-store-aso-sheet.md`](docs/app-store-aso-sheet.md).

## Author

Filippo Cilia

- X: [@fcilia_dev](https://x.com/fcilia_dev)
- Instagram: [@cilippofilia](https://www.instagram.com/cilippofilia)
- App Store: [Drinko](https://apps.apple.com/gb/app/drinko/id6449893371)

## License

This project is proprietary software. All rights reserved.
