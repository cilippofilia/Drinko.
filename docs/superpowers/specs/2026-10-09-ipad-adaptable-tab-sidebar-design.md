# iPad Adaptable Tab Sidebar — Design Spec

- **Date:** 2026-10-09
- **Branch:** `release/3.0`
- **Status:** Approach approved in conversation, pending written-spec review
- **Reference:** Apple News on iPadOS 26 (floating top tab bar that expands into a sidebar with collapsible groups)

## 1. Goal

Replace the iPad layout of the main tabs with the Apple News pattern:

- A floating **tab bar at the top** (Learn, Cabinet, Cocktails, Tools, Settings) with a leading button that expands it into a **sidebar**.
- The sidebar lists the main tabs, then **collapsible groups** that jump straight to filtered content: cocktail filters, Learn topics + Books, individual tools, and Cabinet categories.
- Each page is **full width**: the existing library card grid (with the recents deck on top), and tapping a card **pushes** the detail. No per-tab list/detail split view on iPad.

iPhone keeps its bottom tab bar and looks the same as today. macOS (`MacHomeView`) is unaffected.

## 2. Decisions

| Topic | Decision |
|---|---|
| Container | One `TabView` with `.tabViewStyle(.sidebarAdaptable)` in `HomeView` (replaces `.tabBarOnly`). |
| Sidebar groups | `TabSection`s whose tabs use `.tabPlacement(.sidebarOnly)`, so they never show in the top/bottom tab bar. |
| Groups included | Cocktail filters, Learn topics + Books, individual tools, Cabinet categories (all four). |
| Tab selection type | A typed `AppTab` enum replaces the `String?` tags (`LearnView.learnTag` etc.). |
| iOS page navigation | Each page is a `NavigationStack` with push navigation, on iPhone and iPad alike. iPhone already behaves like this (its split views collapse to a stack), so it looks the same. |
| macOS page navigation | Unchanged: `LearnView`, `CocktailsView`, `ToolsView` keep their `NavigationSplitView` under `#if os(macOS)`. |
| Sidebar customization ("Edit" in News) | Out of scope. |
| Filter pills on pages (News+ "Discover" row) | Out of scope. Possible follow-up. |
| Uncommitted iPad split-view work | Removed (see §7). The debounced recents recording is kept. |

## 3. `AppTab`

New file `DrinkoPro/Helpers/AppTab.swift`, next to `AppNavigationModel.swift`. `Helpers` is a synchronized group in both targets; `AppTab` is iOS-only in use, but compiling it on macOS is harmless.

```swift
enum AppTab: Hashable {
    case learn
    case learnSection(id: String)        // a LearnTopic.id or LessonsViewModel.booksSectionID
    case cabinet
    case cabinetCategory(id: UUID)       // Category.id
    case cocktails
    case cocktailFilter(CocktailsViewModel.FilterOption)
    case tools
    case tool(ToolsView.Selection)
    case settings
}
```

- `RawRepresentable` with a `String` raw value (e.g. `"learn"`, `"learnSection/bar-preps"`, `"cocktailFilter/shotsOnly"`), so `@SceneStorage` can keep restoring the last-used tab. Unknown or stale raw values (a deleted category, a renamed topic) decode to the parent tab.
- `var parent: AppTab` maps every sidebar-only tab to its main tab (e.g. `.cocktailFilter(_) → .cocktails`).
- `FilterOption` and `ToolsView.Selection` need stable string encodings; add them if they don't exist.

`AppNavigationModel.selectedTab` becomes `AppTab` (default `.learn`). `handle(url:)` sets `.cocktails`. The old string tags are deleted; `SettingsView.settingsTag` and friends go with them.

**Compact width:** sidebar-only tabs have nowhere to show in a bottom tab bar. When the horizontal size class is compact and `selectedTab` is a sidebar-only tab (restored from scene storage, or the iPad window was narrowed), `HomeView` switches selection to `selectedTab.parent`. This is pure mapping and lives in `AppTab`, so it can be tested.

## 4. `HomeView` structure

```text
TabView(selection: $appNavigationModel.selectedTab) {
    Tab("Learn", systemImage: "books.vertical", value: .learn) { LearnView() }
    Tab("Cabinet", systemImage: "cabinet", value: .cabinet) { CabinetView() }
    Tab("Cocktails", systemImage: "wineglass", value: .cocktails) { CocktailsView() }
    Tab("Tools", systemImage: "wrench.and.screwdriver", value: .tools) { ToolsView() }
    Tab("Settings", systemImage: "gear", value: .settings) { SettingsView() }

    TabSection("Cocktails") {
        Tab("Shots", systemImage: "drop", value: .cocktailFilter(.shotsOnly)) { CocktailsView(filter: .shotsOnly) }
        Tab("Favorites", systemImage: "heart", value: .cocktailFilter(.favoritesOnly)) { … }
        Tab("My Cocktails", systemImage: "person.crop.circle", value: .cocktailFilter(.userCreatedOnly)) { … }
    }
    TabSection("Learn") {
        ForEach(LearnTopic.all) { Tab(topic.title, systemImage: "book", value: .learnSection(id: topic.id)) { LearnView(sectionID: topic.id) } }
        Tab("Books", systemImage: "books.vertical", value: .learnSection(id: booksSectionID)) { … }
    }
    TabSection("Tools") {
        ForEach(ToolsLibrary.calculatorItems) { Tab(title, systemImage: …, value: .tool(item)) { ToolPage(item) } }
    }
    TabSection("Cabinet") {
        ForEach(categories) { Tab(category.name, systemImage: "tray", value: .cabinetCategory(id: category.id)) { CabinetView(categoryID: category.id) } }
    }
}
.tabViewStyle(.sidebarAdaptable)
```

- All `TabSection` tabs get `.tabPlacement(.sidebarOnly)`.
- Plain "Cocktails" shows everything (the `.all` filter); the user can still change the filter from its menu. The sidebar adds Shots, Favorites and My Cocktails. "Cocktails only" stays reachable from the filter menu.
- `HomeView` gets a `@Query` of categories (same sort as `CabinetView`) to build the Cabinet group. An empty Cabinet means an empty (hidden) group.
- Tool row icons: SF Symbols chosen per tool in `ToolsLibrary` (e.g. `percent` for ABV, `drop` for superjuice), since `Tab` takes a symbol, not the card's asset image.
- Sidebar group titles and row labels are localized like existing strings.
- Everything else on `HomeView` (review prompt, widget tutorial, interstitial ad, scene-storage restore) stays, retyped to `AppTab`.

## 5. Pages

Each page view gains an optional preset and, on iOS, drops the split view.

### Learn
- `LearnView(sectionID: String? = nil)`. With a section ID, the page shows only that section (no recents deck, title = section title). Without it, today's full library.
- iOS: `NavigationStack { LibraryView(...) }` with `.navigationDestination(for: LearnView.Selection.self) { LearnDetailView(selection: $0) }`. Selecting a card appends to the path.

### Cocktails
- `CocktailsView(filter: FilterOption? = nil)`. A preset filter fixes the page's filter and title (e.g. "Shots") and hides the filter options in the menu. Without one, today's behavior.
- iOS: `NavigationStack` with `navigationDestination(for: Cocktail.self)`; the existing "You may also like" pushes keep working inside the same stack.
- The pending-deep-link handling pushes the cocktail onto the stack.

### Tools
- Main Tools tab: `NavigationStack { LibraryView(...) }`, pushing the calculator.
- `.tool(item)` tabs show that calculator directly as the root of its own `NavigationStack` (no list first).

### Cabinet
- `CabinetView(categoryID: UUID? = nil)`. With an ID, the list shows only that category; without, all categories (today's list).
- iOS: `NavigationStack`; selecting a product or category pushes `EditProductView` / `EditCategoryView`. Delete pops back.
- `CabinetView` is iOS-only already, so it simply loses its `NavigationSplitView`.

### Shared
- `.crossPromoBanner()` goes back to one plain call per page (bottom of the stack root), as on iPhone today.
- Each `NavigationStack` path is per tab, so switching tabs keeps each page's position, matching News.

## 6. Recents recording

Keep the debounced recording from the current branch (`RecentsStore.recordDelay` + `.task(id:)`), keyed on the pushed item instead of the split-view selection: when a Learn or Cocktails detail is pushed, its `.task` waits `recordDelay` and records. Tapping a recents card goes through the same path.

## 7. Removed from the current uncommitted work

- `LibrarySidebarList.swift`, `RecentsDetailEmptyState.swift` (deleted).
- `RecentsDeckCard.maxWidth`, `RecentsDeckView.maxCardWidth`, `RecentsDeckLayout.detailEmptyStateMaxCardWidth`.
- `Binding<CollapsedSections>` `isExpanded` subscript (and the `import SwiftUI` change in `CollapsedSections.swift`).
- `crossPromoBanner(isEnabled:)` (back to `crossPromoBanner()`).
- `isRegularWidth`, `searchPlacement`, `navigationSplitViewColumnWidth` and the hidden-layout-toggle branches in all four screens.

## 8. Testing

Unit tests (Swift Testing, new `AppTabTests.swift`):
- Raw-value round trip for every case; unknown/stale raw values decode to the parent tab.
- `parent` for every sidebar-only case.
- `AppNavigationModel.handle(url:)` selects `.cocktails` and sets the pending ID.
- Existing suites (`LibraryModelTests`, `RecentsStoreTests`, `ToolsLibraryTests`, …) keep passing.

Manual / simulator checks (iPad A16 and an iPhone):
- iPad: top tab bar, sidebar toggle, each sidebar group opens the right filtered page, push/pop, recents deck tap, deep link `drinko://cocktail/<id>`.
- iPad narrowed to compact (Split View): bottom tab bar, sidebar-only selection falls back to its parent.
- iPhone: bottom tab bar unchanged, no sidebar groups visible, all flows as before.
- macOS: `DrinkoDesktop` builds and its split views behave as before.
- SwiftLint: no errors.

## 9. Risks

- **iPhone navigation change:** iPhone moves from collapsed split views to `NavigationStack`s. It should look the same, but back-button, state restoration and the deep-link push need checking.
- **Cabinet group size:** many categories make a long sidebar. Acceptable; News does the same.
- **`TabSection` with `ForEach` over SwiftData results:** if a selected category is deleted, selection must fall back to `.cabinet` (handled by observing `categories` in `HomeView`).
