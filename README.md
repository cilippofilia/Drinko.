# Professional cocktails at home

## 📖 About

Whether you're a newbie cocktail enthusiast, aspiring bartender, or simply looking to up your mixology game, **Drinko** is your ultimate guide to the world of bartending. From the basics to advanced techniques, you'll learn insider tips and tricks to craft delicious, Instagram-worthy cocktails. 

Drinko is your one-stop-shop for everything you need to know about the most famous cocktails, their history, and how to make them like a pro. Let's shake things up and get started on your cocktail-making journey!

---

## ✨ Features

### 🎓 Learn Section
Master the art of mixology with comprehensive educational content:
- **Interactive Lessons**: Step-by-step guides covering basic to advanced techniques
- **Video Examples**: Visual demonstrations for all techniques
- **Spirit Guides**: Deep dives into different spirits, liqueurs, and syrups
- **Calculators**: ABV calculator and Superjuice calculator for precise measurements
- **Reference Books**: Curated collection of bartending resources
- **Collapsible Sections**: Organized content for easy navigation

### 🍸 Cocktails Section
Explore an extensive collection of over **130 cocktails**:
- **Comprehensive Database**: Cocktails and shots with detailed recipes
- **Smart Search**: Quickly find your favorite drinks
- **Multiple Sort Options**: Sort by name (A-Z, Z-A), glass type, or ice preference
- **Favorites System**: Swipe to favorite and never lose track of your go-to drinks
- **Detailed Views**: Complete information including:
  - Full ingredient lists with precise measurements
  - Step-by-step preparation procedures
  - Historical context and origins
  - Suggested similar cocktails
  - Glassware and garnish recommendations

### 🗄️ Cabinet Section
Keep track of your ingredients like a professional:
- **Category Management**: Organize ingredients by type (Vodkas, Gins, Whiskeys, Rums, Tequilas, Cognacs, Liqueurs, Juices, Syrups)
- **Product Tracking**: Detailed product information including:
  - Name, details, and origin
  - ABV (Alcohol By Volume)
  - Personal ratings
  - "Tried" status tracking
  - Favorite products
- **Cloud Sync**: Seamlessly sync your cabinet across all your devices using CloudKit
- **Visual Organization**: Color-coded categories for easy identification

### ⚙️ Settings & Localization
- **Multi-language Support**: Fully localized in 4 languages
  - 🇬🇧 English
  - 🇮🇹 Italian
  - 🇫🇷 French
  - 🇩🇪 German
- **Feedback System**: Built-in email composer for bug reports and feedback
- **App Preferences**: Customize your experience
- **App Information**: Version details and credits

### 🎨 Additional Features
- **Beautiful UI**: Modern, native SwiftUI design optimized for iPhone and iPad
- **Smooth Animations**: Polished user experience with thoughtful animations
- **Accessibility**: VoiceOver support and accessibility features
- **In-App Purchases**: Support for tip jar and premium features
- **App Store Integration**: Smart review prompts based on usage

---

## 🛠️ Tech Stack

### Core Technologies
- **Swift 5.9+**: Modern Swift with latest language features
- **SwiftUI**: Declarative UI framework for building native interfaces
- **iOS 17.0+**: Latest iOS features and APIs

### Frameworks & Libraries

| Framework | Purpose | Usage |
|-----------|---------|-------|
| **SwiftData** | Data Persistence | Local storage for Cabinet items (categories and products) |
| **CloudKit** | Cloud Sync | Sync Cabinet data across multiple devices |
| **Combine** | Reactive Programming | Handle async events for in-app purchases |
| **TipKit** | User Guidance | In-app tips and onboarding hints |
| **StoreKit** | In-App Purchases | Support for tip jar and premium features |
| **MessageUI** | Communication | Direct feedback and bug reporting from within the app |

### Design Tools
- **Figma**: Design and prototyping
- **Shots.so**: App screenshots and marketing materials

### Development Tools
- **Xcode**: Primary IDE
- **Git/GitHub**: Version control and collaboration

---

## 🏗️ Architecture

### Project Structure

```
Drinko/
├── DrinkoPro/              # Main iOS app
│   ├── Models/            # Data models (Category, Item)
│   ├── Views/             # SwiftUI views organized by feature
│   │   ├── Cabinet/       # Cabinet feature views
│   │   ├── Cocktails/     # Cocktails feature views
│   │   ├── Learn/         # Learn feature views
│   │   ├── Settings/      # Settings views
│   │   └── Supporting Views/
│   ├── CoreData/          # Data model definitions
│   └── Utilities/         # Helpers and localizations
│
├── DrinkoProMac/          # macOS version
│   └── View/              # macOS-specific views
│
└── Shared/                # Shared code and resources
    ├── Models/            # Shared models (Cocktail, Lesson, Book)
    ├── Views/             # Shared SwiftUI components
    ├── Helpers/           # Utility functions
    ├── Assets.xcassets/   # Images and icons
    └── Utilities/         # JSON data files
```

### Design Patterns

- **MVVM (Model-View-ViewModel)**: Separation of business logic and UI
- **Observable Pattern**: Using `@Observable` for reactive state management
- **NavigationStack**: Modern navigation with type-safe routing
- **Dependency Injection**: Environment objects for shared state (Favorites)

### Data Flow

1. **Cocktails Data**: Loaded from JSON files in bundle at runtime
2. **Cabinet Data**: Persisted locally with SwiftData, synced via CloudKit
3. **Favorites**: Stored in UserDefaults with JSON encoding
4. **Settings**: User preferences stored in UserDefaults

---

## 📋 Requirements

- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later
- **macOS**: 14.0 or later (for macOS version)
- **Swift**: 5.9 or later

---

## 🚀 Getting Started

### Prerequisites

1. Install [Xcode](https://developer.apple.com/xcode/) from the App Store
2. Ensure you have an Apple Developer account (for device testing and CloudKit)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Drinko.git
   cd Drinko
   ```

2. Open the project in Xcode:
   ```bash
   open DrinkoPro.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run (⌘R)

### CloudKit Setup

To enable CloudKit sync for the Cabinet feature:

1. Open the project in Xcode
2. Select the `DrinkoPro` target
3. Go to "Signing & Capabilities"
4. Ensure CloudKit is enabled
5. Configure your CloudKit container in the Apple Developer portal

---

## 🌍 Localization

The app supports multiple languages with automatic language switching based on device settings:

- 🇬🇧 **English** (Base)
- 🇮🇹 **Italian**
- 🇫🇷 **French**
- 🇩🇪 **German**

Localization files are located in:
- `DrinkoPro/Utilities/Localizables/`
- `Shared/Utilities/Localizable.xcstrings`

Want to help translate Drinko into more languages? Get in touch through the Settings section in the app!

---

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution

- 🌍 **Translations**: Help translate the app into more languages
- 🐛 **Bug Reports**: Report issues through the app's Settings section
- 💡 **Feature Ideas**: Share your ideas for new features
- 📖 **Documentation**: Improve code documentation and README

---

## 📝 License

This project is proprietary software. All rights reserved.

---

## 👤 Author

**Filippo Cilia**

- Twitter: [@the_drinko_app](https://x.com/the_drinko_app)
- Instagram: [@drinko_app](https://www.instagram.com/drinko_app)
- App Store: [Download Drinko](https://apps.apple.com/gb/app/drinko/id6449893371)

---

## 🙏 Acknowledgments

- All the cocktail enthusiasts and bartenders who inspired this project
- The SwiftUI community for excellent resources and examples
- Beta testers and users who provided valuable feedback

---

## 📞 Support

Found a bug or have a suggestion? 

- **In-App**: Use the feedback feature in Settings
- **Email**: Contact through the app's Settings section
- **Social Media**: Reach out on [Twitter](https://x.com/the_drinko_app) or [Instagram](https://www.instagram.com/drinko_app)

---

<div align="center">
  
  Made with ❤️ and 🍹 using SwiftUI
  
  [Download on the App Store](https://apps.apple.com/gb/app/drinko/id6449893371)
  
</div>
