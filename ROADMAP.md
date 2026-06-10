# Drinko Roadmap

A prioritized list of enhancements for Drinko. Items move from **Next** to **Now** as work begins; tick them off as they ship.

## Now

- [x] **Configurable widget** — convert "Cocktail of the Day" from `StaticConfiguration` to `AppIntentConfiguration` so users can long-press → Edit Widget:
  - Content source: All Drinks / Cocktails Only / Shots Only / Favorites Only
  - Show/hide the ingredients list on the medium widget
  - Requires an App Group so the widget can read favorites
- [x] **Widget tutorial** — step-by-step "Add a Widget" guide in Settings, shown once automatically after a few app opens
- [x] **Fix widget deployment target** — the widget extension targets a newer iOS than the app, making it invisible on older devices

## Next — high-impact features

- [ ] **"What can I make?"** — cross-reference Cabinet inventory with cocktail recipes to suggest drinks the user can make right now, plus a shopping list of missing ingredients. The Cabinet and Cocktails tabs don't talk to each other today; this is the app's biggest differentiation opportunity.
- [ ] **Lock Screen / StandBy widgets** — add `.accessoryRectangular` and `.accessoryCircular` families showing the daily pick
- [ ] **Large widget** (`.systemLarge`) — full recipe: ingredients, method, glass, and garnish at a glance
- [ ] **Spotlight & Siri via App Intents** — expose cocktails as `AppEntity` so users can search "Negroni" in Spotlight or ask Siri; builds directly on the widget intent work
- [ ] **Photos for Cabinet products** — PhotosPicker + SwiftData external storage so users can photograph their bottles
- [ ] **Daily cocktail notification** — optional local notification deep-linking to the cocktail of the day (reuses the widget's deterministic daily pick)

## Later — engagement & content

- [ ] **TipKit adoption** — contextual tips for under-discovered features (oz/ml converter, favorites swipe, Cabinet)
- [ ] **Tags & spirit-base filtering** — filter cocktails by base spirit (gin, whiskey, rum…) and add a "surprise me" random pick
- [ ] **Shareable cocktail cards** — render a recipe card with `ImageRenderer` and share it
- [ ] **Photos for user-created cocktails**
- [ ] **iCloud sync status indicator** for Cabinet and custom cocktails

## Technical health

- [ ] **Async widget image loading** — `DrinkoWidgetImageStore` uses blocking `Data(contentsOf:)`; migrate to `URLSession` now that the provider is async
- [ ] **macOS feature parity audit** — close gaps between DrinkoMac and the iOS app
- [ ] **iPad layout** — adopt `NavigationSplitView` at regular width
- [ ] **Expand unit tests** — Favorites persistence, deep-link parsing in `AppNavigationModel`, widget catalog pool/pick logic
- [ ] **Accessibility audit** — Dynamic Type at the largest sizes, VoiceOver on custom rows and widget content
- [ ] **Monetization decision** — no IAP exists today; evaluate tip jar vs. one-time unlock for premium content
