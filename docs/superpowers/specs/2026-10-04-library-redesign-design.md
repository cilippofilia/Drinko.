# Library Redesign (Learn + Cocktails) — Design Spec

- **Date:** 2026-10-04
- **Branch:** `release/3.0`
- **Status:** Approved in conversation, pending written-spec review

## 1. Goal

Redo the Learn and Cocktails sidebars as one shared, data-driven "library" component, based on the v3 sketches:

- A **"Last Read" / "Last Viewed" deck carousel** at the top. It holds the 3 most recently opened items and swipes like a deck of cards.
- **Collapsible sections** below it, shown as either a **list** (rounded inset container with rows) or a **block grid** (2-column cards).
- **One list/grid toggle** that applies to both screens and is remembered across view switches and app launches.
- An **optional completion bar** slot on cards and rows, intended for Learn only. Nothing fills it yet (see §9).

"Data driven" means both screens build plain data (sections of items plus a mapping to display models) and one generic view renders it. That replaces the hardcoded topic switches, per-topic `@AppStorage` flags and per-type row views.

## 2. Decisions

| Topic | Decision |
|---|---|
| Shared component | Learn and Cocktails use the same generic `LibraryView<Item>`. |
| Divider in sketch (`——(C)——`) | Only means list **or** grid. They are exclusive modes. |
| Completion bar | Optional slot (`progress: Double?`). Learn only, later. Cocktails never set it. |
| Recents count | 3 |
| Recents look | Stacked deck. Swiping moves the front card to the back, like a deck of cards / Apple's old library UI. |
| Layout toggle | Global (both screens), persisted with `@AppStorage`. |
| Calculators and books | Become sections in the Learn library. |
| Navigation | Keep `NavigationSplitView` on both screens. The library lives in the sidebar column. |
| Data source | Bundled JSON stays. Remote content is a separate future feature. |
| Search | Stays. Results use the current list/grid mode. |
| Carousel header | "Last Read" on Learn, "Last Viewed" on Cocktails. The nav titles stay "Learn" / "Cocktails". |
| Cocktail card content | Title only, bigger image. |
| Architecture | Approach A: generic view plus value-type content plus a card-model closure. No protocol on models. |
| Swipe actions | Replaced by a context menu in both modes. |

## 3. Components

All new types go in `DrinkoPro/Views/Library/`, one type per file.

### 3.1 Value types

```swift
/// Display data for one item in the library.
struct LibraryCardModel: Equatable {
    var title: String
    var subtitle: String?
    var image: LibraryImage
    var imageContentMode: ContentMode   // .fill for lessons/books, .fit (on white) for cocktail photos
    var progress: Double?               // 0...1; nil hides the completion bar
}

enum LibraryImage: Equatable {
    case remote(URL?)      // lessons, books, cocktail photos
    case asset(String)     // calculators ("abv", "lime", "lemon"), user cocktail glass icons
    case symbol(String)    // SF Symbol, e.g. "wineglass" for wine-glass user cocktails
}

struct LibrarySection<Item: Hashable>: Identifiable {
    let id: String         // stable; used for collapse persistence
    var title: String
    var items: [Item]
}

enum LibraryLayout: String {
    case list
    case grid
}
```

`LibraryLayout` is stored under a single `@AppStorage("libraryLayout")` key that both screens read.

### 3.2 Views

| View | Responsibility |
|---|---|
| `LibraryView<Item: Hashable, Menu: View>` | The sidebar body. It is a `ScrollView` containing the recents deck, then the sections. It takes: `recentsTitle`, `recents: [Item]`, `sections: [LibrarySection<Item>]`, `selection: Binding<Item?>`, `isSearching: Bool`, `collapseStorageKey: String`, `cardModel: (Item) -> LibraryCardModel`, `contextMenu: (Item) -> Menu`. |
| `RecentsDeckView` | The deck carousel (§6.1). |
| `LibrarySectionView` | Collapsible header plus the section's items in the current layout. |
| `LibraryCardView` | Grid card: image on top, title, optional subtitle, optional progress bar along the bottom. |
| `LibraryRowView` | List row: thumbnail with the progress slot under it, title, subtitle limited to 2 lines. |
| `LibraryLayoutToggle` | Toolbar button that switches list/grid. |
| `LibraryProgressBar` | The completion bar. It only appears when `progress != nil`. |

`LibraryView` renders no empty or search states itself. Screens keep their `ContentUnavailableView`s and choose between them and `LibraryView`.

### 3.3 State

- **`RecentsStore`**: a `@MainActor @Observable` class.
  - It keeps an ordered list of ID strings per namespace (`"learn"`, `"cocktails"`) in an injected `UserDefaults`, which defaults to `.standard`.
  - `record(_ id:, in namespace:)` moves the ID to the front, removes duplicates and caps the list at 3.
  - `ids(in namespace:) -> [String]` reads the list back.
  - It is injected through `.environment` in the app root and in `drinkoPreviewEnvironment()`.
- **Collapsed sections**: one persisted `Set<String>` of section IDs per screen (`learnCollapsedSections`, `cocktailsCollapsedSections`). It is stored in `@AppStorage` as a `RawRepresentable` wrapper (`CollapsedSections`) and encoded as a JSON string.

### 3.4 Removed

- `LessonRowView`, `BookRowView`, `ABVRowView`, `SuperjuiceRowView`, `CocktailRowView`, `LearnHeaderView`.
- In `LearnView`: the 9 collapse `@AppStorage` flags and `isCollapsed(for:)` / `setCollapsed(for:value:)`.
- In `LessonsViewModel`: the 7 per-topic properties and the `getLessons(for:)` switch.

Before deleting each type, check for other usages, including widget and macOS targets.

## 4. Learn data flow

- **Topic manifest** in `LessonsViewModel`:
  ```swift
  struct LearnTopic: Identifiable { let id: String; let title: String }   // id == JSON file name
  static let topics: [LearnTopic] = [
      .init(id: "basic-lessons", title: "Basic Lessons"),
      .init(id: "bar-preps", title: "Bar Preps"),
      .init(id: "basic-spirits", title: "Basic Spirits"),
      .init(id: "advanced-spirits", title: "Advanced Spirits"),
      .init(id: "liqueurs", title: "Liqueurs"),
      .init(id: "advanced-lessons", title: "Advanced Lessons"),
      .init(id: "syrups", title: "Syrups")
  ]
  ```
  - Lessons are decoded into `lessonsByTopic: [String: [Lesson]]`.
  - Adding a topic means adding one manifest entry and one JSON file.
  - `allLessons` and the existing filter APIs stay available for any current callers, for example Spotlight or widgets if they use them.
- **`LearnView.Selection`** stays the `Item` type and gets `var id: String`:
  - `lesson:<id>`
  - `book:<id>`
  - `abv`
  - `superjuice:lime` / `superjuice:lemon`
- **`librarySections(matching query: String) -> [LibrarySection<Selection>]`** returns the manifest topics in order, then `calculators` ("Calculators": ABV, Superjuice lime, Superjuice lemon), then `books` ("Books").
  - A non-empty trimmed query filters each section and drops empty ones.
  - Lessons match on title/description, books on title/description/author, calculators on title.
  - Matching uses `localizedStandardContains`.
- **Card mapping** (`cardModel(for: Selection) -> LibraryCardModel`, on the view model):
  - Lesson: `title`, `description`, `.remote(lesson.image)`, `.fill`, `progress: nil`.
  - Book: `title`, `"© author"`, `.remote(book.image)`, `.fill`.
  - ABV: "ABV Calculator", the current row's description, `.asset("abv")`, `.fit`.
  - Superjuice: "Lime Superjuice" / "Lemon Superjuice", the current row's description, `.asset("lime"/"lemon")`, `.fit`.
- **Recents resolution**: `recentItems(from ids: [String]) -> [Selection]` maps the stored IDs back to selections and drops any it can't resolve.

## 5. Cocktails data flow

- **`CocktailsViewModel.librarySections(filterOption:source:isFavorite:)`** wraps the existing `groupedCocktails` and `sortedSectionKeys`. Section `id` and `title` are the existing section key, so sort, filter, source and A–Z/glass/ice grouping behave exactly as today.
  - **Change:** search results are now grouped the same way, not a flat list.
- **Card mapping** (`cardModel(for: Cocktail)`):
  - Title is `name` and there is no subtitle.
  - App cocktails: `.remote(URL(string: pic))`, `.fit` on a white background.
  - User cocktails (`id.hasPrefix("user-")`):
    - `wine` → `.symbol("wineglass")`
    - `coffee mug` / `julep cup` → `.asset("julep")`
    - everything else → `.asset(glass)`
    - All of these are shown on a tinted background.
- **Context menu**:
  - Favorite / Unfavorite.
  - Delete for user cocktails only. It sets `cocktailPendingDeletion` and shows the existing alert.
- **Toolbar**: the existing filter/sort menu, the `LibraryLayoutToggle`, and **+** (create).
- **Kept as is**:
  - `CocktailsView.contentView` keeps choosing between `LibraryView` and the existing `ContentUnavailableView`s (filter empty state, search empty state).
  - The `listSource` change handling.
  - Deep links (`pendingCocktailID` → selection).
  - The detail `NavigationStack` with "You may also like".
- **Recents resolution**: stored IDs → `listOfAllDrinks`. IDs that don't resolve are dropped, for example deleted user cocktails.

## 6. Behaviour

### 6.1 Recents deck

- A `ZStack` of up to 3 cards built from `LibraryCardModel` (they look like grid cards).
  - The front card is centered.
  - The second peeks out on the right, slightly smaller and tilted.
  - The third peeks out on the left, smaller and tilted the other way.
- Card width: `.containerRelativeFrame(.horizontal)` at about 60% of the column.
- Header above the deck: the `recentsTitle` ("Last Read" / "Last Viewed").
- **Drag**: the front card follows a horizontal drag and tilts with it.
  - Past a distance or predicted-end threshold, it animates off and moves to the back. The next card springs forward.
  - Under the threshold, it springs back.
  - Swiping only changes the deck order and never opens anything.
- **Tap** on the front card sets `selection`.
- The deck order is local `@State`. It resets to recency order whenever `recents` changes.
- 1–2 recents: a smaller deck. 0 recents, or while searching: the deck and header are hidden.
- **Reduce Motion**: cards cross-fade, with no fly-out or tilt.
- **VoiceOver**: one element.
  - Label: "<recentsTitle>, <n> of <count>, <title>".
  - `accessibilityAdjustableAction` cycles the cards.
  - The default action opens the front card.

### 6.2 Sections

- The header is a `Button` with the title and a rotating chevron, using the `.isHeader` trait. It toggles the collapse with animation.
- Collapsed IDs persist per screen.
- **While searching**, every section shows expanded, whatever its stored collapsed state. The stored state is left unchanged.

### 6.3 Layouts

- **Grid**: `LazyVGrid` with `GridItem(.adaptive(minimum:))`. That gives 2 columns in the iPhone/iPad sidebar and more when the macOS sidebar is wider.
  - Card image: a fixed aspect ratio, clipped with `.clipShape(.rect(cornerRadius: imageCornerRadius))`.
- **List**: one rounded inset container per section with inset dividers between rows.
  - Row thumbnail size comes from `@ScaledMetric`.
  - Remote images use the existing `CachedRemoteImage`.
- **Selection highlight**: an accent-colored border in grid mode, a filled background in list mode.
- **Item interaction**: a `Button` that sets `selection`, with `.contextMenu` from the screen's builder.
- **Accessibility**: each item is one element with title (and subtitle) as label/value, plus the `.isSelected` trait when selected.

### 6.4 Recording recents

- Each screen calls `recentsStore.record(selection.id, in: <namespace>)` in `onChange(of: selection) { _, new in ... }` when `new != nil`.
- That covers sidebar taps, deck taps and deep links.

### 6.5 Style constraints

- Dynamic Type throughout, with no fixed font sizes.
- No hardcoded padding or spacing unless needed for the deck geometry.
- `.foregroundStyle`, `.clipShape(.rect(...))`, `Button(_:systemImage:action:)` for icon buttons.
- No `GeometryReader` if `containerRelativeFrame` or `visualEffect` works. No UIKit/AppKit.
- `#if os` only where the platforms truly differ. The `CrossPromoBannerView` safe-area inset is kept on both screens.

## 7. Testing

Swift Testing, in `DrinkoProTests/`, for logic only:

- **RecentsStore**
  - `record` moves an item to the front, removes duplicates and caps at 3.
  - It persists across instances, using a dedicated `UserDefaults(suiteName:)`.
  - Namespaces are isolated.
- **CollapsedSections**: the raw value round-trips, and an invalid raw value gives an empty set.
- **LearnView.Selection.id**: IDs are stable and unique across all cases.
- **LessonsViewModel**
  - `librarySections("")` returns the manifest order plus Calculators and Books, with no section left empty.
  - A query filters lessons, books and calculators and drops empty sections.
  - A whitespace-only query returns everything.
  - `recentItems` resolves IDs in order and drops unknown ones.
  - `cardModel` gives lessons `progress == nil` and the expected subtitles.
- **CocktailsViewModel**
  - `librarySections` matches `sortedSectionKeys` / `groupedCocktails` for every sort option, filter and source.
  - `cardModel`: no subtitle; user cocktails map to the correct asset or symbol; app cocktails map to `.remote`.
  - Recents resolution drops deleted IDs.

**Manual checks**:

- Previews for each library view, in both layouts, with 0/1/3 recents.
- Build the iOS and macOS targets.
- Run the existing test suite.
- `swiftlint` reports no errors.

## 8. Risks

- **Losing `List(selection:)`**: native selection, keyboard navigation and sidebar styling are gone on macOS/iPad. We use our own highlight, and arrow-key navigation is not supported in v3.0.
- **Lazy loading**: `ScrollView` + `LazyVStack` / `LazyVGrid` keeps images lazy. Cocktails have about 100+ items; check scrolling performance.
- **Deck gesture vs. scroll**: the horizontal drag must not steal vertical scrolling. Only recognize clearly horizontal drags.

## 9. Out of scope

- Tracking or storing completion progress. Only the UI slot exists, and `progress` is always `nil`.
- Remote or downloaded content.
- Changes to detail views (lesson, book, calculators, cocktail).
- Widgets, Spotlight and App Intents, beyond keeping them compiling.
