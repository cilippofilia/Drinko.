# Library Redesign (Learn + Cocktails) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Learn and Cocktails sidebars with one shared, data-driven `LibraryView`. It has a "Last Read" / "Last Viewed" deck carousel, collapsible sections, and a remembered list/grid toggle.

**Architecture:** Each screen builds plain value data and hands it to a generic `LibraryView<Item, MenuContent>`:
- `[LibrarySection<Item>]`
- resolved recent items
- an `(Item) -> LibraryCardModel` mapping

The data-building logic lives in view-model extensions and is unit-tested. The views only render `LibraryCardModel`. `RecentsStore` (`@Observable`, `UserDefaults`) keeps the last 3 opened IDs per screen. Collapsed-section and layout state go in `@AppStorage`.

**Tech Stack:** Swift 6, SwiftUI (iOS 26 / macOS 26), Observation, Swift Testing (new tests), XCTest (existing `LessonsViewModelTests`), SwiftLint.

**Spec:** `docs/superpowers/specs/2026-10-04-library-redesign-design.md`

## Global Constraints

- Target iOS 26 / macOS 26 and Swift 6 strict concurrency. Every `@Observable` class is `@MainActor`.
- No third-party dependencies. No UIKit/AppKit in new code.
- One type per Swift file. New library types go in `DrinkoPro/Views/Library/`.
- The Xcode project uses **file-system synchronized groups**: new files under `DrinkoPro/` and `DrinkoProTests/` are picked up automatically. Never edit `project.pbxproj`.
- `.foregroundStyle`, `.clipShape(.rect(cornerRadius:))`, `Button(_:systemImage:action:)` for icon buttons, never `.onTapGesture`.
- `.onChange` only in its 0- or 2-parameter forms. No `GeometryReader`. No `AnyView`. No `DispatchQueue`.
- Dynamic Type everywhere, with no fixed font sizes. Size images with `@ScaledMetric`.
- User-text filtering uses `localizedStandardContains`.
- Cocktail cards show the **title only** (no subtitle). `progress` is always `nil` in this plan.
- One global layout key `libraryLayout`, default `.list`.
- Recents capacity is **3**. Namespaces are `learn` and `cocktails`. Carousel titles are "Last Read" (Learn) and "Last Viewed" (Cocktails).
- `NavigationSplitView` stays on both screens. Arrow-key navigation is knowingly dropped.
- SwiftLint (`swiftlint` at `/opt/homebrew/bin/swiftlint`) must report **0 errors** before each commit.
- Commit messages end with: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`

**Commands used throughout** (run from the repo root `/Users/filippocilia/Desktop/Projects/iOS/Drinko`):

```bash
# Run one test suite (replace <Suite> with the struct/class name)
xcodebuild test -project DrinkoPro.xcodeproj -scheme DrinkoPro \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:DrinkoProTests/<Suite> 2>&1 | grep -E "Test (Suite|Case)|✔|✘|error:|passed|failed|BUILD" | tail -40

# Build iOS app
xcodebuild build -project DrinkoPro.xcodeproj -scheme DrinkoPro \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' 2>&1 | grep -E "error:|BUILD" | tail -20

# Build macOS app
xcodebuild build -project DrinkoPro.xcodeproj -scheme DrinkoDesktop \
  -destination 'platform=macOS' 2>&1 | grep -E "error:|BUILD" | tail -20

# Lint
swiftlint lint --quiet | grep -c " error: " ; swiftlint lint --quiet | grep " error: "
```

## Spec deviations decided while planning (all intentional)

1. **`CocktailRowView` is kept.** `LinkedCocktailsView` ("You may also like" in the detail view) still uses it. Only its use in the sidebar goes away.
2. **`LibraryView` takes `selection: Item?` (read-only, for the highlight) plus an `onSelect` closure**, not a `Binding`. Each screen's `select(_:)` does three things: sets the selection, sets `preferredCompactColumn = .detail`, and records the recent. This is required so iPhone (compact width) pushes the detail when a custom button is tapped, including re-tapping the same item after going back. Recording happens in `select(_:)` and in the Cocktails deep-link path, not in `onChange`.
3. **`LibraryView` takes `collapsedSections: Binding<CollapsedSections>` and `layout: LibraryLayout`.** Each screen owns the `@AppStorage`, because the toolbar toggle lives in the screen.
4. **Reduce Motion in the deck**: no drag-follow, no tilt, and the cards swap without animation.
5. `LessonsViewModel` moves from `Lesson.swift` into its own file. `LearnTopic` gets its own file. This follows the one-type-per-file rule.

## Review Focus

1. **iPhone compact navigation:** tapping a row/card, or the front deck card, must push the detail. So must tapping the *same* item again after going back. Covered by `preferredCompactColumn` in Tasks 9 and 10, with manual checks in Task 11.
2. **Search while a section is collapsed:** matching items must still show, and tapping a header during search must not change the stored collapsed state. Covered by the `CollapsedSections.isCollapsed(_:whileSearching:)` tests in Task 1 and the disabled header in Task 6.
3. **Stale or corrupt persisted data**:
   - A deleted user cocktail or removed lesson in recents must disappear silently. Tests in Tasks 4 and 5.
   - An invalid `CollapsedSections` raw value gives an empty set. Test in Task 1.
   - More than 3 stored recent IDs are truncated on read. Test in Task 2.
4. **Re-opening an already-recent item** moves it to the front without duplicating it, including when it's opened from the deck. Test in Task 2.
5. **Search results grouping:** Cocktails search results must keep the same grouping and order as the non-search list. Learn calculator search must find "ABV". Tests in Tasks 4 and 5.

---

## File Structure

| Path | Action | Responsibility |
|---|---|---|
| `DrinkoPro/Views/Library/LibraryCardModel.swift` | Create | Display model for one item |
| `DrinkoPro/Views/Library/LibraryImage.swift` | Create | Image source enum |
| `DrinkoPro/Views/Library/LibrarySection.swift` | Create | Generic section value |
| `DrinkoPro/Views/Library/LibraryLayout.swift` | Create | list/grid enum + storage key |
| `DrinkoPro/Views/Library/CollapsedSections.swift` | Create | Persisted set of collapsed section IDs |
| `DrinkoPro/Views/Library/RecentsStore.swift` | Create | Last-3 IDs per namespace |
| `DrinkoPro/Views/Library/RecentsDeckLayout.swift` | Create | Pure deck index math |
| `DrinkoPro/Views/Library/LibraryImageView.swift` | Create | Renders a `LibraryImage` |
| `DrinkoPro/Views/Library/LibraryProgressBar.swift` | Create | Completion bar |
| `DrinkoPro/Views/Library/LibraryRowView.swift` | Create | List row |
| `DrinkoPro/Views/Library/LibraryCardView.swift` | Create | Grid card (also used by the deck) |
| `DrinkoPro/Views/Library/LibraryItemButton.swift` | Create | Select button + context menu + a11y wrapper |
| `DrinkoPro/Views/Library/LibrarySectionHeader.swift` | Create | Collapsible header |
| `DrinkoPro/Views/Library/LibrarySectionView.swift` | Create | Header + items in list or grid |
| `DrinkoPro/Views/Library/LibraryLayoutToggle.swift` | Create | Toolbar toggle |
| `DrinkoPro/Views/Library/RecentsDeckView.swift` | Create | Deck carousel |
| `DrinkoPro/Views/Library/LibraryView.swift` | Create | Full sidebar body |
| `DrinkoPro/Models/Learn/LearnTopic.swift` | Create | Topic manifest |
| `DrinkoPro/Models/Learn/LessonsViewModel.swift` | Create (moved) | Manifest-driven lessons |
| `DrinkoPro/Models/Learn/LessonsViewModel+Library.swift` | Create | Learn sections, card models, recents |
| `DrinkoPro/Models/Cocktails/CocktailsViewModel+Library.swift` | Create | Cocktail sections, card models, recents |
| `DrinkoPro/Models/Learn/Lesson.swift` | Modify | Remove the view model |
| `DrinkoPro/Views/Learn/LearnView+Selection.swift` | Modify | Add `Identifiable` / `id` |
| `DrinkoPro/Views/Learn/LearnView.swift` | Rewrite | Use `LibraryView` |
| `DrinkoPro/Views/Cocktails/CocktailsView.swift` | Modify | Use `LibraryView` |
| `DrinkoPro/Helpers/GlobalConstant.swift` | Modify | Add `libraryCardCornerRadius` |
| `DrinkoPro/DrinkoProApp.swift` | Modify | Inject `RecentsStore` |
| `DrinkoPro/Models/Samples/Samples+Ext.swift` | Modify | Preview `RecentsStore` |
| `DrinkoPro/Views/Learn/Lessons/LessonRowView.swift`, `Views/Learn/BookRowView.swift`, `Views/Learn/ABV/ABVRowView.swift`, `Views/Learn/Superjuice/SuperjuiceRowView.swift`, `Views/Learn/Lessons/LearnHeaderView.swift` | Delete | Replaced |
| `DrinkoProTests/LibraryModelTests.swift` | Create | Tests for Task 1 |
| `DrinkoProTests/RecentsStoreTests.swift` | Create | Tests for Task 2 |
| `DrinkoProTests/LessonsViewModelTests.swift` | Rewrite | Tests for Task 3 |
| `DrinkoProTests/LearnLibraryTests.swift` | Create | Tests for Task 4 |
| `DrinkoProTests/CocktailsLibraryTests.swift` | Create | Tests for Task 5 |
| `DrinkoProTests/RecentsDeckLayoutTests.swift` | Create | Tests for Task 7 |

---

### Task 1: Library value types

**Files:**
- Create: `DrinkoPro/Views/Library/LibraryCardModel.swift`, `LibraryImage.swift`, `LibrarySection.swift`, `LibraryLayout.swift`, `CollapsedSections.swift`
- Modify: `DrinkoPro/Helpers/GlobalConstant.swift`
- Test: `DrinkoProTests/LibraryModelTests.swift`

**Interfaces:**
- Produces:
  - `LibraryCardModel(title:subtitle:image:imageContentMode:progress:)`
  - `LibraryImage.remote(URL?) / .asset(String) / .symbol(String)`
  - `LibrarySection<Item: Hashable>(id:title:items:)` (`Identifiable, Hashable`)
  - `LibraryLayout.list/.grid` with `LibraryLayout.storageKey == "libraryLayout"` and `toggled`
  - `CollapsedSections`: `RawRepresentable<String>`, with `init()`, `contains(_:)`, `isCollapsed(_:whileSearching:)`, `mutating toggle(_:)`
  - Global `libraryCardCornerRadius: CGFloat`

- [ ] **Step 1: Write the failing tests**

`DrinkoProTests/LibraryModelTests.swift`:

```swift
import Foundation
import Testing
@testable import DrinkoPro

@Suite("Library models")
struct LibraryModelTests {
    @Test func collapsedSectionsStartsEmpty() {
        let sections = CollapsedSections()
        #expect(!sections.contains("basic-lessons"))
    }

    @Test func toggleAddsThenRemovesAnID() {
        var sections = CollapsedSections()
        sections.toggle("books")
        #expect(sections.contains("books"))
        sections.toggle("books")
        #expect(!sections.contains("books"))
    }

    @Test func rawValueRoundTrips() throws {
        var sections = CollapsedSections()
        sections.toggle("books")
        sections.toggle("syrups")
        let restored = try #require(CollapsedSections(rawValue: sections.rawValue))
        #expect(restored == sections)
    }

    @Test func invalidRawValueGivesEmptySet() throws {
        let restored = try #require(CollapsedSections(rawValue: "not json"))
        #expect(restored == CollapsedSections())
    }

    @Test func searchingForcesSectionsOpen() {
        var sections = CollapsedSections()
        sections.toggle("books")
        #expect(sections.isCollapsed("books", whileSearching: false))
        #expect(!sections.isCollapsed("books", whileSearching: true))
        #expect(!sections.isCollapsed("syrups", whileSearching: false))
    }

    @Test func layoutTogglesAndUsesSharedKey() {
        #expect(LibraryLayout.list.toggled == .grid)
        #expect(LibraryLayout.grid.toggled == .list)
        #expect(LibraryLayout.storageKey == "libraryLayout")
        #expect(LibraryLayout(rawValue: "garbage") == nil)
    }

    @Test func cardModelDefaultsHaveNoSubtitleOrProgress() {
        let model = LibraryCardModel(title: "Negroni", image: .symbol("wineglass"))
        #expect(model.subtitle == nil)
        #expect(model.progress == nil)
        #expect(model.imageContentMode == .fill)
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the suite command with `<Suite>` = `LibraryModelTests`.
Expected: build failure, `cannot find 'CollapsedSections' in scope`.

- [ ] **Step 3: Implement the types**

`DrinkoPro/Views/Library/LibraryImage.swift`:

```swift
//
//  LibraryImage.swift
//  DrinkoPro
//

import Foundation

/// Where a library card or row gets its artwork from.
enum LibraryImage: Hashable {
    /// A remote photo, loaded through `CachedRemoteImage`.
    case remote(URL?)
    /// An image from the asset catalog.
    case asset(String)
    /// An SF Symbol name.
    case symbol(String)
}
```

`DrinkoPro/Views/Library/LibraryCardModel.swift`:

```swift
//
//  LibraryCardModel.swift
//  DrinkoPro
//

import SwiftUI

/// Display data for one item shown by `LibraryView`, independent of the model it came from.
struct LibraryCardModel: Hashable {
    var title: String
    var subtitle: String?
    var image: LibraryImage
    var imageContentMode: ContentMode
    /// Completion between 0 and 1. `nil` hides the completion bar.
    var progress: Double?

    init(
        title: String,
        subtitle: String? = nil,
        image: LibraryImage,
        imageContentMode: ContentMode = .fill,
        progress: Double? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageContentMode = imageContentMode
        self.progress = progress
    }
}
```

`DrinkoPro/Views/Library/LibrarySection.swift`:

```swift
//
//  LibrarySection.swift
//  DrinkoPro
//

import Foundation

/// A titled group of items shown by `LibraryView`.
struct LibrarySection<Item: Hashable>: Identifiable, Hashable {
    /// Stable identifier, also used to persist the collapsed state.
    let id: String
    var title: String
    var items: [Item]
}
```

`DrinkoPro/Views/Library/LibraryLayout.swift`:

```swift
//
//  LibraryLayout.swift
//  DrinkoPro
//

import Foundation

/// How library sections present their items. Shared by every library screen.
enum LibraryLayout: String, CaseIterable {
    case list
    case grid

    /// The `@AppStorage` key shared by Learn and Cocktails.
    static let storageKey = "libraryLayout"

    /// The other layout.
    var toggled: LibraryLayout {
        self == .list ? .grid : .list
    }
}
```

`DrinkoPro/Views/Library/CollapsedSections.swift`:

```swift
//
//  CollapsedSections.swift
//  DrinkoPro
//

import Foundation

/// The IDs of collapsed library sections, storable in `@AppStorage`.
struct CollapsedSections: RawRepresentable, Equatable {
    private var ids: Set<String>

    init() {
        ids = []
    }

    /// Decodes a JSON array of IDs. Invalid data yields an empty set rather than failing.
    init?(rawValue: String) {
        let decoded = try? JSONDecoder().decode(Set<String>.self, from: Data(rawValue.utf8))
        ids = decoded ?? []
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(ids.sorted()) else { return "[]" }
        return String(decoding: data, as: UTF8.self)
    }

    func contains(_ id: String) -> Bool {
        ids.contains(id)
    }

    /// Whether a section should render collapsed. Searching always shows every section expanded.
    func isCollapsed(_ id: String, whileSearching isSearching: Bool) -> Bool {
        !isSearching && contains(id)
    }

    mutating func toggle(_ id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
    }
}
```

In `DrinkoPro/Helpers/GlobalConstant.swift`, add this below `let imageFrameHeight: CGFloat = 280`:

```swift
let libraryCardCornerRadius: CGFloat = 16
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run the suite command with `<Suite>` = `LibraryModelTests`. Expected: all 7 tests pass.

- [ ] **Step 5: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "   # expect no output
git add DrinkoPro/Views/Library DrinkoPro/Helpers/GlobalConstant.swift DrinkoProTests/LibraryModelTests.swift
git commit -m "Add library value types for shared Learn/Cocktails view

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: RecentsStore

**Files:**
- Create: `DrinkoPro/Views/Library/RecentsStore.swift`
- Modify: `DrinkoPro/DrinkoProApp.swift`, `DrinkoPro/Models/Samples/Samples+Ext.swift`
- Test: `DrinkoProTests/RecentsStoreTests.swift`

**Interfaces:**
- Produces:
  - `RecentsStore(defaults: UserDefaults = .standard)`
  - `RecentsStore.Namespace.learn / .cocktails`
  - `RecentsStore.capacity == 3`
  - `ids(in: Namespace) -> [String]`
  - `record(_ id: String, in: Namespace)`
  - Injected with `.environment(recentsStore)` in the app and `drinkoPreviewEnvironment()`.

- [ ] **Step 1: Write the failing tests**

`DrinkoProTests/RecentsStoreTests.swift`:

```swift
import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("RecentsStore")
struct RecentsStoreTests {
    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "RecentsStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func startsEmpty() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        #expect(store.ids(in: .learn).isEmpty)
        #expect(store.ids(in: .cocktails).isEmpty)
    }

    @Test func recordPutsNewestFirst() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        store.record("a", in: .learn)
        store.record("b", in: .learn)
        #expect(store.ids(in: .learn) == ["b", "a"])
    }

    @Test func recordingAnExistingIDMovesItToFrontWithoutDuplicating() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        store.record("a", in: .learn)
        store.record("b", in: .learn)
        store.record("a", in: .learn)
        #expect(store.ids(in: .learn) == ["a", "b"])
    }

    @Test func keepsAtMostThree() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        for id in ["a", "b", "c", "d"] {
            store.record(id, in: .cocktails)
        }
        #expect(store.ids(in: .cocktails) == ["d", "c", "b"])
    }

    @Test func namespacesAreIsolated() throws {
        let store = RecentsStore(defaults: try makeDefaults())
        store.record("lesson:ice", in: .learn)
        store.record("negroni", in: .cocktails)
        #expect(store.ids(in: .learn) == ["lesson:ice"])
        #expect(store.ids(in: .cocktails) == ["negroni"])
    }

    @Test func persistsAcrossInstances() throws {
        let defaults = try makeDefaults()
        RecentsStore(defaults: defaults).record("negroni", in: .cocktails)
        #expect(RecentsStore(defaults: defaults).ids(in: .cocktails) == ["negroni"])
    }

    @Test func truncatesOverlongStoredLists() throws {
        let defaults = try makeDefaults()
        defaults.set(["a", "b", "c", "d", "e"], forKey: "recents.learn")
        #expect(RecentsStore(defaults: defaults).ids(in: .learn) == ["a", "b", "c"])
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the suite command with `<Suite>` = `RecentsStoreTests`. Expected: build failure, `cannot find 'RecentsStore' in scope`.

- [ ] **Step 3: Implement `RecentsStore`**

`DrinkoPro/Views/Library/RecentsStore.swift`:

```swift
//
//  RecentsStore.swift
//  DrinkoPro
//

import Foundation
import Observation

/// Remembers the most recently opened library items for each library screen.
@MainActor
@Observable
final class RecentsStore {
    enum Namespace: String, CaseIterable {
        case learn
        case cocktails
    }

    /// How many recent items each namespace keeps.
    static let capacity = 3

    @ObservationIgnored private let defaults: UserDefaults
    private var idsByNamespace: [Namespace: [String]] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        for namespace in Namespace.allCases {
            let stored = defaults.stringArray(forKey: Self.key(for: namespace)) ?? []
            idsByNamespace[namespace] = Array(stored.prefix(Self.capacity))
        }
    }

    /// Recent IDs for `namespace`, newest first.
    func ids(in namespace: Namespace) -> [String] {
        idsByNamespace[namespace] ?? []
    }

    /// Moves `id` to the front of `namespace`, removing duplicates and trimming to `capacity`.
    func record(_ id: String, in namespace: Namespace) {
        var ids = ids(in: namespace)
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        ids = Array(ids.prefix(Self.capacity))
        idsByNamespace[namespace] = ids
        defaults.set(ids, forKey: Self.key(for: namespace))
    }

    private static func key(for namespace: Namespace) -> String {
        "recents.\(namespace.rawValue)"
    }
}
```

- [ ] **Step 4: Inject it**

In `DrinkoPro/DrinkoProApp.swift`, add this after `@State private var appNavigationModel = AppNavigationModel()`:

```swift
    @State private var recentsStore = RecentsStore()
```

and this after `.environment(appNavigationModel)`:

```swift
        .environment(recentsStore)
```

In `DrinkoPro/Models/Samples/Samples+Ext.swift`, add this after `static let lessonsViewModel = LessonsViewModel()`:

```swift
    static let recentsStore = RecentsStore(defaults: UserDefaults(suiteName: "PreviewRecents") ?? .standard)
```

and in `drinkoPreviewEnvironment()`, add this after `.environment(PreviewSupport.lessonsViewModel)`:

```swift
            .environment(PreviewSupport.recentsStore)
```

- [ ] **Step 5: Run the tests and confirm they pass**

Run the suite command with `<Suite>` = `RecentsStoreTests`. Expected: all 7 tests pass.

- [ ] **Step 6: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Views/Library/RecentsStore.swift DrinkoPro/DrinkoProApp.swift DrinkoPro/Models/Samples/Samples+Ext.swift DrinkoProTests/RecentsStoreTests.swift
git commit -m "Add RecentsStore for last opened library items

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Manifest-driven LessonsViewModel

**Files:**
- Create: `DrinkoPro/Models/Learn/LearnTopic.swift`, `DrinkoPro/Models/Learn/LessonsViewModel.swift`
- Modify: `DrinkoPro/Models/Learn/Lesson.swift` (delete the `LessonsViewModel` class, lines 31–129)
- Rewrite: `DrinkoProTests/LessonsViewModelTests.swift`

**Interfaces:**
- Produces:
  - `LearnTopic(id:title:)`, `LearnTopic.all: [LearnTopic]`
  - `LessonsViewModel(topics: [LearnTopic] = LearnTopic.all)`
  - `topics: [LearnTopic]`, `books: [Book]`, `allLessons: [Lesson]` (in manifest order)
  - `lessons(for topicID: String) -> [Lesson]`
  - `filteredLessons(for:matching:)`, `filteredBooks(matching:)`, `hasResults(matching:)`. These keep their current signatures, and `for` is now a topic ID.
- Removed: `basicLessons`, `advancedLessons`, `barPreps`, `basicSpirits`, `advancedSpirits`, `liqueurs`, `syrups`, `getLessons(for:)`. The only callers are `LearnView` (rewritten in Task 9) and tests.

`LearnView` still compiles after this task: it uses `viewModel.topics` in `ForEach(viewModel.topics, id: \.self)`, which `LearnTopic` (Hashable) still satisfies. But it passes `topic` to `filteredLessons(for: topic ...)`, `isCollapsed(for: topic)` and `topic.replacing(...)`, which all expect a `String`. Step 4 adds a minimal bridge so the app keeps building until Task 9.

- [ ] **Step 1: Rewrite the tests**

Replace `DrinkoProTests/LessonsViewModelTests.swift` entirely:

```swift
import XCTest
@testable import DrinkoPro

@MainActor
final class LessonsViewModelTests: XCTestCase {
    func testTopicManifestOrder() {
        XCTAssertEqual(
            LearnTopic.all.map(\.id),
            [
                "basic-lessons",
                "bar-preps",
                "basic-spirits",
                "advanced-spirits",
                "liqueurs",
                "advanced-lessons",
                "syrups"
            ]
        )
        XCTAssertEqual(LessonsViewModel().topics, LearnTopic.all)
    }

    func testEveryTopicLoadsLessonsFromBundle() {
        let viewModel = LessonsViewModel()

        for topic in viewModel.topics {
            XCTAssertFalse(viewModel.lessons(for: topic.id).isEmpty, "No lessons for \(topic.id)")
        }
        XCTAssertFalse(viewModel.books.isEmpty)
    }

    func testUnknownTopicHasNoLessons() {
        XCTAssertTrue(LessonsViewModel().lessons(for: "unknown-topic").isEmpty)
    }

    func testAllLessonsFollowsManifestOrder() {
        let viewModel = LessonsViewModel()
        let expectedIds = viewModel.topics.flatMap { viewModel.lessons(for: $0.id).map(\.id) }

        XCTAssertEqual(viewModel.allLessons.map(\.id), expectedIds)
    }

    func testFilteredLessonsWithEmptyQueryReturnsEverything() {
        let viewModel = LessonsViewModel()
        let basics = viewModel.lessons(for: "basic-lessons")

        XCTAssertEqual(viewModel.filteredLessons(for: "basic-lessons", matching: ""), basics)
        XCTAssertEqual(viewModel.filteredLessons(for: "basic-lessons", matching: "   "), basics)
    }

    func testFilteredLessonsMatchesTitleOrDescriptionCaseInsensitively() throws {
        let viewModel = LessonsViewModel()
        let lesson = try XCTUnwrap(viewModel.lessons(for: "basic-lessons").first)

        let byTitle = viewModel.filteredLessons(for: "basic-lessons", matching: lesson.title.uppercased())
        XCTAssertTrue(byTitle.contains(lesson))

        let byDescriptionFragment = String(lesson.description.prefix(4))
        let byDescription = viewModel.filteredLessons(for: "basic-lessons", matching: byDescriptionFragment)
        XCTAssertTrue(byDescription.contains(lesson))
    }

    func testFilteredLessonsWithNoMatchReturnsEmpty() {
        let viewModel = LessonsViewModel()

        XCTAssertTrue(
            viewModel.filteredLessons(for: "basic-lessons", matching: "zzzzz-no-such-lesson-zzzzz").isEmpty
        )
    }

    func testFilteredBooksWithEmptyQueryReturnsEverything() {
        let viewModel = LessonsViewModel()

        XCTAssertEqual(viewModel.filteredBooks(matching: ""), viewModel.books)
        XCTAssertEqual(viewModel.filteredBooks(matching: "  "), viewModel.books)
    }

    func testFilteredBooksMatchesTitleDescriptionOrAuthor() throws {
        let viewModel = LessonsViewModel()
        let book = try XCTUnwrap(viewModel.books.first)

        XCTAssertTrue(viewModel.filteredBooks(matching: book.title.uppercased()).contains(book))
        XCTAssertTrue(viewModel.filteredBooks(matching: book.author).contains(book))
    }

    func testFilteredBooksWithNoMatchReturnsEmpty() {
        XCTAssertTrue(LessonsViewModel().filteredBooks(matching: "zzzzz-no-such-book-zzzzz").isEmpty)
    }

    func testHasResultsIsTrueForEmptyQuery() {
        XCTAssertTrue(LessonsViewModel().hasResults(matching: ""))
    }

    func testHasResultsIsTrueWhenABookMatches() throws {
        let viewModel = LessonsViewModel()
        let book = try XCTUnwrap(viewModel.books.first)

        XCTAssertTrue(viewModel.hasResults(matching: book.title))
    }

    func testHasResultsIsTrueWhenALessonMatches() throws {
        let viewModel = LessonsViewModel()
        let lesson = try XCTUnwrap(viewModel.lessons(for: "basic-lessons").first)

        XCTAssertTrue(viewModel.hasResults(matching: lesson.title))
    }

    func testHasResultsIsFalseWhenNothingMatches() {
        XCTAssertFalse(LessonsViewModel().hasResults(matching: "zzzzz-no-such-content-zzzzz"))
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the suite command with `<Suite>` = `LessonsViewModelTests`. Expected: build failure, `cannot find 'LearnTopic' in scope`.

- [ ] **Step 3: Create the manifest and move the view model**

`DrinkoPro/Models/Learn/LearnTopic.swift`:

```swift
//
//  LearnTopic.swift
//  DrinkoPro
//

import Foundation

/// One Learn topic. `id` is also the name of the bundled JSON file holding its lessons.
struct LearnTopic: Identifiable, Hashable {
    let id: String
    let title: String

    /// Every topic, in display order. Add a topic by adding an entry here and a `<id>.json` file.
    static let all: [LearnTopic] = [
        LearnTopic(id: "basic-lessons", title: String(localized: "Basic Lessons")),
        LearnTopic(id: "bar-preps", title: String(localized: "Bar Preps")),
        LearnTopic(id: "basic-spirits", title: String(localized: "Basic Spirits")),
        LearnTopic(id: "advanced-spirits", title: String(localized: "Advanced Spirits")),
        LearnTopic(id: "liqueurs", title: String(localized: "Liqueurs")),
        LearnTopic(id: "advanced-lessons", title: String(localized: "Advanced Lessons")),
        LearnTopic(id: "syrups", title: String(localized: "Syrups"))
    ]
}
```

`DrinkoPro/Models/Learn/LessonsViewModel.swift`:

```swift
//
//  LessonsViewModel.swift
//  DrinkoPro
//

import Foundation
import Observation

@MainActor
@Observable
class LessonsViewModel {
    let topics: [LearnTopic]
    private(set) var lessonsByTopic: [String: [Lesson]]
    var books: [Book] = Bundle.main.decode([Book].self, from: "books.json")

    init(topics: [LearnTopic] = LearnTopic.all) {
        self.topics = topics
        var lessons: [String: [Lesson]] = [:]
        for topic in topics {
            lessons[topic.id] = Bundle.main.decode([Lesson].self, from: "\(topic.id).json")
        }
        lessonsByTopic = lessons
    }

    /// Every lesson, in topic manifest order.
    var allLessons: [Lesson] {
        topics.flatMap { lessons(for: $0.id) }
    }

    func lessons(for topicID: String) -> [Lesson] {
        lessonsByTopic[topicID] ?? []
    }

    /// Returns the lessons for `topicID` whose title or description match `query`.
    ///
    /// Whitespace is trimmed from `query`; an empty (or whitespace-only) query returns every
    /// lesson for that topic unfiltered.
    func filteredLessons(for topicID: String, matching query: String) -> [Lesson] {
        let lessons = lessons(for: topicID)
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return lessons }

        return lessons.filter { lesson in
            lesson.title.localizedStandardContains(trimmedQuery) ||
            lesson.description.localizedStandardContains(trimmedQuery)
        }
    }

    /// Returns the books whose title, description or author match `query`.
    ///
    /// Whitespace is trimmed from `query`; an empty (or whitespace-only) query returns every book
    /// unfiltered.
    func filteredBooks(matching query: String) -> [Book] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return books }

        return books.filter { book in
            book.title.localizedStandardContains(trimmedQuery) ||
            book.description.localizedStandardContains(trimmedQuery) ||
            book.author.localizedStandardContains(trimmedQuery)
        }
    }

    /// Whether any lesson (across all topics) or book matches `query`.
    ///
    /// An empty (or whitespace-only) query always returns `true`.
    func hasResults(matching query: String) -> Bool {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return true }

        if !filteredBooks(matching: query).isEmpty {
            return true
        }

        return topics.contains { !filteredLessons(for: $0.id, matching: query).isEmpty }
    }
}
```

In `DrinkoPro/Models/Learn/Lesson.swift`, delete everything from `@MainActor` / `@Observable` / `class LessonsViewModel {` through the closing `}` at the end of the file. `Lesson` and `LessonContent` stay.

- [ ] **Step 4: Keep `LearnView` compiling until Task 9**

In `DrinkoPro/Views/Learn/LearnView.swift`, replace both occurrences of `ForEach(viewModel.topics, id: \.self) { topic in` with:

```swift
ForEach(viewModel.topics.map(\.id), id: \.self) { topic in
```

This is temporary; Task 9 rewrites the file.

- [ ] **Step 5: Run the tests and build**

Run the suite command with `<Suite>` = `LessonsViewModelTests`. Expected: all 14 tests pass. Then run the iOS build command. Expected: `BUILD SUCCEEDED`.

- [ ] **Step 6: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Models/Learn DrinkoPro/Views/Learn/LearnView.swift DrinkoProTests/LessonsViewModelTests.swift
git commit -m "Drive Learn topics from a manifest instead of hardcoded properties

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Learn library content

**Files:**
- Modify: `DrinkoPro/Views/Learn/LearnView+Selection.swift`
- Create: `DrinkoPro/Models/Learn/LessonsViewModel+Library.swift`
- Test: `DrinkoProTests/LearnLibraryTests.swift`

**Interfaces:**
- Consumes: `LibrarySection`, `LibraryCardModel`, `LibraryImage` (Task 1), `LessonsViewModel` (Task 3).
- Produces:
  - `LearnView.Selection: Identifiable` with `id: String` (`lesson:<id>`, `book:<id>`, `abv`, `superjuice:<type>`)
  - `LessonsViewModel.calculatorsSectionID == "calculators"` and `booksSectionID == "books"`
  - `librarySections(matching:) -> [LibrarySection<LearnView.Selection>]`
  - `cardModel(for: LearnView.Selection) -> LibraryCardModel`
  - `recentItems(from: [String]) -> [LearnView.Selection]`
  - `allItems: [LearnView.Selection]`

- [ ] **Step 1: Write the failing tests**

`DrinkoProTests/LearnLibraryTests.swift`:

```swift
import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Learn library content")
struct LearnLibraryTests {
    let viewModel = LessonsViewModel()

    @Test func selectionIDsAreStableAndUnique() throws {
        let lesson = try #require(viewModel.allLessons.first)
        let book = try #require(viewModel.books.first)
        #expect(LearnView.Selection.lesson(lesson).id == "lesson:\(lesson.id)")
        #expect(LearnView.Selection.book(book).id == "book:\(book.id)")
        #expect(LearnView.Selection.abvCalculator.id == "abv")
        #expect(LearnView.Selection.superjuice("lime").id == "superjuice:lime")

        let ids = viewModel.allItems.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func emptyQueryReturnsManifestThenCalculatorsThenBooks() {
        let sections = viewModel.librarySections(matching: "")
        #expect(sections.map(\.id) == LearnTopic.all.map(\.id) + ["calculators", "books"])
        #expect(sections.allSatisfy { !$0.items.isEmpty })
        #expect(sections.first { $0.id == "calculators" }?.items == [.abvCalculator, .superjuice("lime"), .superjuice("lemon")])
    }

    @Test func whitespaceQueryMatchesEmptyQuery() {
        #expect(viewModel.librarySections(matching: "   ") == viewModel.librarySections(matching: ""))
    }

    @Test func queryFiltersItemsAndDropsEmptySections() throws {
        let lesson = try #require(viewModel.lessons(for: "syrups").first)
        let sections = viewModel.librarySections(matching: lesson.title)
        #expect(sections.allSatisfy { !$0.items.isEmpty })
        let syrups = try #require(sections.first { $0.id == "syrups" })
        #expect(syrups.items.contains(.lesson(lesson)))
    }

    @Test func calculatorsAreSearchable() throws {
        let sections = viewModel.librarySections(matching: "abv")
        let calculators = try #require(sections.first { $0.id == "calculators" })
        #expect(calculators.items == [.abvCalculator])
    }

    @Test func noMatchReturnsNoSections() {
        #expect(viewModel.librarySections(matching: "zzzzz-no-such-content-zzzzz").isEmpty)
    }

    @Test func recentItemsResolveInOrderAndDropUnknownIDs() throws {
        let lesson = try #require(viewModel.allLessons.first)
        let items = viewModel.recentItems(from: ["abv", "lesson:does-not-exist", "lesson:\(lesson.id)"])
        #expect(items == [.abvCalculator, .lesson(lesson)])
    }

    @Test func cardModels() throws {
        let lesson = try #require(viewModel.allLessons.first)
        let lessonModel = viewModel.cardModel(for: .lesson(lesson))
        #expect(lessonModel.title == lesson.title)
        #expect(lessonModel.subtitle == lesson.description)
        #expect(lessonModel.image == .remote(URL(string: lesson.image)))
        #expect(lessonModel.progress == nil)

        let book = try #require(viewModel.books.first)
        #expect(viewModel.cardModel(for: .book(book)).subtitle == "© \(book.author)")

        #expect(viewModel.cardModel(for: .abvCalculator).image == .asset("abv"))
        #expect(viewModel.cardModel(for: .superjuice("lemon")).image == .asset("lemon"))
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the suite command with `<Suite>` = `LearnLibraryTests`. Expected: build failure, `value of type 'LessonsViewModel' has no member 'librarySections'`.

- [ ] **Step 3: Give `Selection` a stable ID**

Replace the body of `DrinkoPro/Views/Learn/LearnView+Selection.swift` after the header with:

```swift
import Foundation

extension LearnView {
    /// The item shown in the detail column of the Learn split view.
    enum Selection: Hashable, Identifiable {
        case lesson(Lesson)
        case book(Book)
        case abvCalculator
        case superjuice(String)

        /// A stable string identity, used for recents and persistence.
        var id: String {
            switch self {
            case .lesson(let lesson): "lesson:\(lesson.id)"
            case .book(let book): "book:\(book.id)"
            case .abvCalculator: "abv"
            case .superjuice(let juiceType): "superjuice:\(juiceType)"
            }
        }
    }
}
```

- [ ] **Step 4: Implement the library content**

`DrinkoPro/Models/Learn/LessonsViewModel+Library.swift`:

```swift
//
//  LessonsViewModel+Library.swift
//  DrinkoPro
//

import Foundation

extension LessonsViewModel {
    static let calculatorsSectionID = "calculators"
    static let booksSectionID = "books"
    private static let superjuiceTypes = ["lime", "lemon"]

    /// The calculator entries shown in the Calculators section, in display order.
    var calculatorItems: [LearnView.Selection] {
        [.abvCalculator] + Self.superjuiceTypes.map { .superjuice($0) }
    }

    /// Every item the Learn library can show.
    var allItems: [LearnView.Selection] {
        allLessons.map { .lesson($0) } + calculatorItems + books.map { .book($0) }
    }

    /// Topic sections in manifest order, then Calculators, then Books.
    ///
    /// A non-empty (trimmed) `query` filters every section and drops the ones left empty.
    func librarySections(matching query: String) -> [LibrarySection<LearnView.Selection>] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var sections = topics.map { topic in
            LibrarySection(
                id: topic.id,
                title: topic.title,
                items: filteredLessons(for: topic.id, matching: trimmedQuery).map { LearnView.Selection.lesson($0) }
            )
        }

        let calculators = calculatorItems.filter { item in
            trimmedQuery.isEmpty || cardModel(for: item).title.localizedStandardContains(trimmedQuery)
        }
        sections.append(
            LibrarySection(id: Self.calculatorsSectionID, title: String(localized: "Calculators"), items: calculators)
        )
        sections.append(
            LibrarySection(
                id: Self.booksSectionID,
                title: String(localized: "Books"),
                items: filteredBooks(matching: trimmedQuery).map { LearnView.Selection.book($0) }
            )
        )

        return sections.filter { !$0.items.isEmpty }
    }

    /// Display data for one Learn item.
    func cardModel(for item: LearnView.Selection) -> LibraryCardModel {
        switch item {
        case .lesson(let lesson):
            LibraryCardModel(
                title: lesson.title,
                subtitle: lesson.description,
                image: .remote(URL(string: lesson.image))
            )
        case .book(let book):
            LibraryCardModel(
                title: book.title,
                subtitle: "© \(book.author)",
                image: .remote(URL(string: book.image))
            )
        case .abvCalculator:
            LibraryCardModel(
                title: String(localized: "ABV Calculator"),
                subtitle: String(localized: "Work out the alcohol by volume of any drink."),
                image: .asset("abv"),
                imageContentMode: .fit
            )
        case .superjuice(let juiceType):
            LibraryCardModel(
                title: String(localized: "\(juiceType.capitalizingFirstLetter()) Superjuice"),
                subtitle: String(localized: "Turn a few fruits into a litre of juice."),
                image: .asset(juiceType)
            )
        }
    }

    /// Maps stored recent IDs back to items, keeping order and dropping IDs that no longer exist.
    func recentItems(from ids: [String]) -> [LearnView.Selection] {
        let itemsByID = Dictionary(allItems.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { itemsByID[$0] }
    }
}
```

- [ ] **Step 5: Run the tests and confirm they pass**

Run the suite command with `<Suite>` = `LearnLibraryTests`. Expected: all 8 tests pass. If `calculatorsAreSearchable` fails, check that `cardModel(for: .abvCalculator).title` is "ABV Calculator".

- [ ] **Step 6: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Views/Learn/LearnView+Selection.swift DrinkoPro/Models/Learn/LessonsViewModel+Library.swift DrinkoProTests/LearnLibraryTests.swift
git commit -m "Build Learn library sections, card models and recents from data

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Cocktails library content

**Files:**
- Create: `DrinkoPro/Models/Cocktails/CocktailsViewModel+Library.swift`
- Test: `DrinkoProTests/CocktailsLibraryTests.swift`

**Interfaces:**
- Consumes: Task 1 types and the existing `CocktailsViewModel.groupedCocktails(filterOption:source:isFavorite:)` / `sortedSectionKeys(filterOption:source:isFavorite:)`.
- Produces:
  - `CocktailsViewModel.librarySections(filterOption:source:isFavorite:) -> [LibrarySection<Cocktail>]`
  - `cardModel(for: Cocktail) -> LibraryCardModel`
  - `recentItems(from: [String]) -> [Cocktail]`

- [ ] **Step 1: Write the failing tests**

`DrinkoProTests/CocktailsLibraryTests.swift`:

```swift
import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("Cocktails library content")
struct CocktailsLibraryTests {
    private func userCocktail(glass: String) -> Cocktail {
        Cocktail(
            id: "user-test-\(glass)",
            name: "Mine",
            method: "stir",
            glass: glass,
            garnish: "-",
            ice: "-",
            extra: "-",
            ingredients: []
        )
    }

    @Test(arguments: [SortOption.fromAtoZ, .fromZtoA, .byGlass, .byIce])
    func sectionsMatchExistingGrouping(sortOption: SortOption) {
        let viewModel = CocktailsViewModel()
        viewModel.sortOption = sortOption

        let sections = viewModel.librarySections(filterOption: .all) { _ in false }
        let keys = viewModel.sortedSectionKeys(filterOption: .all) { _ in false }
        let grouped = viewModel.groupedCocktails(filterOption: .all) { _ in false }

        #expect(sections.map(\.id) == keys)
        #expect(sections.map(\.title) == keys)
        #expect(sections.map(\.items) == keys.map { grouped[$0] ?? [] })
    }

    @Test func sectionsRespectFilterAndSource() {
        let viewModel = CocktailsViewModel()
        let sections = viewModel.librarySections(filterOption: .shotsOnly, source: .appOnly) { _ in false }
        let shotIDs = Set(viewModel.listOfShots.map(\.id))

        #expect(!sections.isEmpty)
        #expect(sections.flatMap(\.items).allSatisfy { shotIDs.contains($0.id) })
    }

    @Test func searchKeepsGrouping() throws {
        let viewModel = CocktailsViewModel()
        let first = try #require(viewModel.listOfCocktails.first)
        viewModel.searchText = first.name

        let sections = viewModel.librarySections(filterOption: .all) { _ in false }
        #expect(sections.flatMap(\.items).contains(first))
        #expect(sections.map(\.id) == viewModel.sortedSectionKeys(filterOption: .all) { _ in false })
    }

    @Test func appCocktailCardIsTitleOnlyRemotePhoto() throws {
        let viewModel = CocktailsViewModel()
        let cocktail = try #require(viewModel.listOfCocktails.first)
        let model = viewModel.cardModel(for: cocktail)

        #expect(model.title == cocktail.name)
        #expect(model.subtitle == nil)
        #expect(model.progress == nil)
        #expect(model.image == .remote(URL(string: cocktail.pic)))
        #expect(model.imageContentMode == .fit)
    }

    @Test func userCocktailCardsUseGlassArtwork() {
        let viewModel = CocktailsViewModel()
        #expect(viewModel.cardModel(for: userCocktail(glass: "wine")).image == .symbol("wineglass"))
        #expect(viewModel.cardModel(for: userCocktail(glass: "julep cup")).image == .asset("julep"))
        #expect(viewModel.cardModel(for: userCocktail(glass: "coffee mug")).image == .asset("julep"))
        #expect(viewModel.cardModel(for: userCocktail(glass: "coupe")).image == .asset("coupe"))
    }

    @Test func recentItemsDropUnknownIDs() throws {
        let viewModel = CocktailsViewModel()
        let first = try #require(viewModel.listOfCocktails.first)
        let shot = try #require(viewModel.listOfShots.first)

        let items = viewModel.recentItems(from: [shot.id, "user-deleted", first.id])
        #expect(items == [shot, first])
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the suite command with `<Suite>` = `CocktailsLibraryTests`. Expected: build failure, `value of type 'CocktailsViewModel' has no member 'librarySections'`.

- [ ] **Step 3: Implement**

`DrinkoPro/Models/Cocktails/CocktailsViewModel+Library.swift`:

```swift
//
//  CocktailsViewModel+Library.swift
//  DrinkoPro
//

import Foundation

extension CocktailsViewModel {
    /// The current cocktail list as library sections, using the active sort, search, filter and source.
    func librarySections(
        filterOption: FilterOption,
        source: CocktailListSource = .userAndApp,
        isFavorite: (Cocktail) -> Bool
    ) -> [LibrarySection<Cocktail>] {
        let grouped = groupedCocktails(filterOption: filterOption, source: source, isFavorite: isFavorite)
        let keys = sortedSectionKeys(filterOption: filterOption, source: source, isFavorite: isFavorite)
        return keys.map { key in
            LibrarySection(id: key, title: key, items: grouped[key] ?? [])
        }
    }

    /// Display data for a cocktail: title only, photo for app cocktails, glass artwork for the user's own.
    func cardModel(for cocktail: Cocktail) -> LibraryCardModel {
        LibraryCardModel(title: cocktail.name, image: libraryImage(for: cocktail), imageContentMode: .fit)
    }

    /// Maps stored recent IDs back to cocktails, keeping order and dropping deleted ones.
    func recentItems(from ids: [String]) -> [Cocktail] {
        let drinksByID = Dictionary(listOfAllDrinks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { drinksByID[$0] }
    }

    private func libraryImage(for cocktail: Cocktail) -> LibraryImage {
        guard cocktail.id.hasPrefix("user-") else {
            return .remote(URL(string: cocktail.pic))
        }

        switch cocktail.glass {
        case "wine":
            return .symbol("wineglass")
        case "coffee mug", "julep cup":
            return .asset("julep")
        default:
            return .asset(cocktail.image)
        }
    }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run the suite command with `<Suite>` = `CocktailsLibraryTests`. Expected: 9 test cases pass (4 parameterized + 5).

- [ ] **Step 5: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Models/Cocktails/CocktailsViewModel+Library.swift DrinkoProTests/CocktailsLibraryTests.swift
git commit -m "Build Cocktails library sections, card models and recents from data

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Library leaf views (image, progress, row, card, item button, header, section, toggle)

**Files:**
- Create in `DrinkoPro/Views/Library/`: `LibraryImageView.swift`, `LibraryProgressBar.swift`, `LibraryRowView.swift`, `LibraryCardView.swift`, `LibraryItemButton.swift`, `LibrarySectionHeader.swift`, `LibrarySectionView.swift`, `LibraryLayoutToggle.swift`

**Interfaces:**
- Consumes: Task 1 types, `CachedRemoteImage(url:contentMode:)`, `imageCornerRadius`, `libraryCardCornerRadius`.
- Produces:
  - `LibraryImageView(image:contentMode:)`
  - `LibraryProgressBar(progress:)`
  - `LibraryRowView(model:isSelected:)`
  - `LibraryCardView(model:isSelected:)`
  - `LibraryItemButton(isSelected:action:label:contextMenu:)`
  - `LibrarySectionHeader(title:isCollapsed:isEnabled:action:)`
  - `LibrarySectionView<Item, MenuContent>(section:layout:isCollapsed:isCollapsible:selection:onToggleCollapsed:onSelect:cardModel:contextMenu:)`
  - `LibraryLayoutToggle(layout: Binding<LibraryLayout>)`

These are pure presentation views, so there are no unit tests. Verify them with previews and a build.

- [ ] **Step 1: `LibraryImageView`**

```swift
//
//  LibraryImageView.swift
//  DrinkoPro
//

import SwiftUI

/// Renders a `LibraryImage`. Remote photos sit on white (cocktail photos have white backgrounds);
/// fitted assets and symbols sit on a tinted fill.
struct LibraryImageView: View {
    let image: LibraryImage
    let contentMode: ContentMode

    var body: some View {
        Group {
            switch image {
            case .remote(let url):
                CachedRemoteImage(url: url, contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
            case .asset(let name):
                if contentMode == .fit {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.fill.tertiary)
                } else {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            case .symbol(let name):
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.fill.tertiary)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack {
        LibraryImageView(image: .symbol("wineglass"), contentMode: .fit)
        LibraryImageView(image: .asset("coupe"), contentMode: .fit)
        LibraryImageView(image: .asset("lime"), contentMode: .fill)
    }
    .frame(height: 100)
}
#endif
```

- [ ] **Step 2: `LibraryProgressBar`**

```swift
//
//  LibraryProgressBar.swift
//  DrinkoPro
//

import SwiftUI

/// The optional completion bar shown under library thumbnails and cards.
struct LibraryProgressBar: View {
    let progress: Double

    var body: some View {
        ProgressView(value: min(max(progress, 0), 1))
            .progressViewStyle(.linear)
            .accessibilityLabel("Completion")
    }
}

#if DEBUG
#Preview {
    LibraryProgressBar(progress: 0.4)
        .padding()
}
#endif
```

- [ ] **Step 3: `LibraryRowView`**

```swift
//
//  LibraryRowView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's list layout.
struct LibraryRowView: View {
    @ScaledMetric private var thumbnailSize: CGFloat = 56

    let model: LibraryCardModel
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack {
                LibraryImageView(image: model.image, contentMode: model.imageContentMode)
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipShape(.rect(cornerRadius: imageCornerRadius))

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                        .frame(width: thumbnailSize)
                }
            }

            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.headline)

                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background {
            if isSelected {
                Rectangle().fill(.tint.opacity(0.15))
            }
        }
        .contentShape(.rect)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        LibraryRowView(
            model: LibraryCardModel(title: "Ice", subtitle: "Why ice matters more than you think.", image: .symbol("cube"), imageContentMode: .fit, progress: 0.5),
            isSelected: true
        )
        LibraryRowView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit), isSelected: false)
    }
}
#endif
```

- [ ] **Step 4: `LibraryCardView`**

```swift
//
//  LibraryCardView.swift
//  DrinkoPro
//

import SwiftUI

/// One item in a library section's grid layout. Also used for the recents deck.
struct LibraryCardView: View {
    let model: LibraryCardModel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay {
                    LibraryImageView(image: model.image, contentMode: model.imageContentMode)
                }
                .clipped()

            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.headline)
                    .lineLimit(2)

                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let progress = model.progress {
                    LibraryProgressBar(progress: progress)
                }
            }
            .multilineTextAlignment(.leading)
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: libraryCardCornerRadius)
                .strokeBorder(.tint, lineWidth: 2)
                .opacity(isSelected ? 1 : 0)
        }
        .contentShape(.rect(cornerRadius: libraryCardCornerRadius))
    }
}

#if DEBUG
#Preview {
    HStack(alignment: .top) {
        LibraryCardView(
            model: LibraryCardModel(title: "Ice", subtitle: "Why ice matters more than you think.", image: .symbol("cube"), imageContentMode: .fit, progress: 0.3),
            isSelected: true
        )
        LibraryCardView(model: LibraryCardModel(title: "Negroni", image: .symbol("wineglass"), imageContentMode: .fit), isSelected: false)
    }
    .padding()
}
#endif
```

- [ ] **Step 5: `LibraryItemButton`**

```swift
//
//  LibraryItemButton.swift
//  DrinkoPro
//

import SwiftUI

/// Wraps a row or card so it selects its item, offers the screen's context menu,
/// and reads as a single accessible element.
struct LibraryItemButton<Label: View, MenuContent: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label
    @ViewBuilder let contextMenu: () -> MenuContent

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(.plain)
            .contextMenu(menuItems: contextMenu)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
```

- [ ] **Step 6: `LibrarySectionHeader`**

```swift
//
//  LibrarySectionHeader.swift
//  DrinkoPro
//

import SwiftUI

/// A tappable section title with a chevron that collapses or expands the section.
struct LibrarySectionHeader: View {
    let title: String
    let isCollapsed: Bool
    /// `false` while searching: every section is forced open and the header can't change that.
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    .opacity(isEnabled ? 1 : 0)
                Text(title)
                Spacer()
            }
            .font(.title3.bold())
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
        .accessibilityValue(isEnabled ? (isCollapsed ? "Collapsed" : "Expanded") : "")
        .accessibilityHint(isEnabled ? "Double tap to \(isCollapsed ? "expand" : "collapse") this section." : "")
    }
}

#if DEBUG
#Preview {
    VStack {
        LibrarySectionHeader(title: "Basic Lessons", isCollapsed: false, isEnabled: true) { }
        LibrarySectionHeader(title: "Books", isCollapsed: true, isEnabled: true) { }
    }
    .padding()
}
#endif
```

- [ ] **Step 7: `LibrarySectionView`**

```swift
//
//  LibrarySectionView.swift
//  DrinkoPro
//

import SwiftUI

/// A collapsible section showing its items as a list or a grid.
struct LibrarySectionView<Item: Hashable, MenuContent: View>: View {
    @ScaledMetric private var gridMinimumWidth: CGFloat = 140

    let section: LibrarySection<Item>
    let layout: LibraryLayout
    let isCollapsed: Bool
    let isCollapsible: Bool
    let selection: Item?
    let onToggleCollapsed: () -> Void
    let onSelect: @MainActor (Item) -> Void
    let cardModel: @MainActor (Item) -> LibraryCardModel
    @ViewBuilder let contextMenu: @MainActor (Item) -> MenuContent

    var body: some View {
        VStack(alignment: .leading) {
            LibrarySectionHeader(
                title: section.title,
                isCollapsed: isCollapsed,
                isEnabled: isCollapsible,
                action: onToggleCollapsed
            )

            if !isCollapsed {
                switch layout {
                case .list:
                    LazyVStack(spacing: 0) {
                        ForEach(section.items, id: \.self) { item in
                            LibraryItemButton(isSelected: selection == item) {
                                onSelect(item)
                            } label: {
                                LibraryRowView(model: cardModel(item), isSelected: selection == item)
                            } contextMenu: {
                                contextMenu(item)
                            }

                            if item != section.items.last {
                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                    .background(.background.secondary)
                    .clipShape(.rect(cornerRadius: libraryCardCornerRadius))
                case .grid:
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: gridMinimumWidth), alignment: .top)]) {
                        ForEach(section.items, id: \.self) { item in
                            LibraryItemButton(isSelected: selection == item) {
                                onSelect(item)
                            } label: {
                                LibraryCardView(model: cardModel(item), isSelected: selection == item)
                            } contextMenu: {
                                contextMenu(item)
                            }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        LibrarySectionView(
            section: LibrarySection(id: "demo", title: "Demo", items: ["Negroni", "Daiquiri", "Martini"]),
            layout: .grid,
            isCollapsed: false,
            isCollapsible: true,
            selection: "Daiquiri",
            onToggleCollapsed: { },
            onSelect: { _ in },
            cardModel: { LibraryCardModel(title: $0, image: .symbol("wineglass"), imageContentMode: .fit) },
            contextMenu: { _ in EmptyView() }
        )
        .padding()
    }
}
#endif
```

- [ ] **Step 8: `LibraryLayoutToggle`**

```swift
//
//  LibraryLayoutToggle.swift
//  DrinkoPro
//

import SwiftUI

/// Toolbar button that switches every library between list and grid layouts.
struct LibraryLayoutToggle: View {
    @Binding var layout: LibraryLayout

    private var title: LocalizedStringKey {
        layout == .list ? "Grid View" : "List View"
    }

    private var systemImage: String {
        layout == .list ? "square.grid.2x2" : "list.bullet"
    }

    var body: some View {
        Button(title, systemImage: systemImage) {
            withAnimation(.snappy) {
                layout = layout.toggled
            }
        }
    }
}
```

- [ ] **Step 9: Build and check previews**

Run the iOS build command. Expected: `BUILD SUCCEEDED`. If the `@MainActor` closure types cause isolation errors in previews, keep the `@MainActor` annotation on the stored closure types. Previews run on the main actor, so the inline closures there are fine. Optionally render the `LibrarySectionView` preview with the Xcode MCP `RenderPreview` tool to check it visually.

- [ ] **Step 10: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Views/Library
git commit -m "Add library row, card, section and layout toggle views

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: Recents deck

**Files:**
- Create: `DrinkoPro/Views/Library/RecentsDeckLayout.swift`, `DrinkoPro/Views/Library/RecentsDeckView.swift`
- Test: `DrinkoProTests/RecentsDeckLayoutTests.swift`

**Interfaces:**
- Consumes: `LibraryCardView`, `LibraryCardModel`.
- Produces:
  - `RecentsDeckLayout.position(ofIndex:frontIndex:count:) -> Int`
  - `RecentsDeckLayout.nextFront(_:count:) -> Int`
  - `RecentsDeckLayout.previousFront(_:count:) -> Int`
  - `RecentsDeckView<Item: Hashable>(title:items:cardModel:onOpen:)`

- [ ] **Step 1: Write the failing tests**

`DrinkoProTests/RecentsDeckLayoutTests.swift`:

```swift
import Testing
@testable import DrinkoPro

@Suite("Recents deck layout")
struct RecentsDeckLayoutTests {
    @Test func frontItemIsPositionZero() {
        #expect(RecentsDeckLayout.position(ofIndex: 0, frontIndex: 0, count: 3) == 0)
        #expect(RecentsDeckLayout.position(ofIndex: 2, frontIndex: 2, count: 3) == 0)
    }

    @Test func positionsWrapAround() {
        #expect(RecentsDeckLayout.position(ofIndex: 0, frontIndex: 1, count: 3) == 2)
        #expect(RecentsDeckLayout.position(ofIndex: 2, frontIndex: 1, count: 3) == 1)
    }

    @Test func nextAndPreviousCycle() {
        #expect(RecentsDeckLayout.nextFront(2, count: 3) == 0)
        #expect(RecentsDeckLayout.previousFront(0, count: 3) == 2)
        #expect(RecentsDeckLayout.nextFront(0, count: 1) == 0)
    }

    @Test func emptyDeckIsSafe() {
        #expect(RecentsDeckLayout.nextFront(0, count: 0) == 0)
        #expect(RecentsDeckLayout.previousFront(0, count: 0) == 0)
        #expect(RecentsDeckLayout.position(ofIndex: 0, frontIndex: 0, count: 0) == 0)
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run the suite command with `<Suite>` = `RecentsDeckLayoutTests`. Expected: build failure, `cannot find 'RecentsDeckLayout' in scope`.

- [ ] **Step 3: Implement `RecentsDeckLayout`**

```swift
//
//  RecentsDeckLayout.swift
//  DrinkoPro
//

import Foundation

/// Index math for the recents deck, where cards cycle front-to-back.
enum RecentsDeckLayout {
    /// The depth of the card at `index` when `frontIndex` is on top (0 = front).
    static func position(ofIndex index: Int, frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((index - frontIndex) % count + count) % count
    }

    /// The front index after the top card moves to the back.
    static func nextFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex + 1) % count
    }

    /// The front index after the back card returns to the top.
    static func previousFront(_ frontIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (frontIndex - 1 + count) % count
    }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run the suite command with `<Suite>` = `RecentsDeckLayoutTests`. Expected: all 4 pass.

- [ ] **Step 5: Implement `RecentsDeckView`**

```swift
//
//  RecentsDeckView.swift
//  DrinkoPro
//

import SwiftUI

/// The "Last Read" / "Last Viewed" carousel: up to three stacked cards that swipe like a deck.
///
/// Swiping sends the front card to the back. Tapping the front card opens it.
struct RecentsDeckView<Item: Hashable>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let items: [Item]
    let cardModel: @MainActor (Item) -> LibraryCardModel
    let onOpen: @MainActor (Item) -> Void

    @State private var frontIndex = 0
    @State private var dragOffset: CGFloat = 0

    /// How far (including predicted momentum) a drag must travel to send the card to the back.
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .accessibilityHidden(true)

            ZStack {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    let position = RecentsDeckLayout.position(ofIndex: index, frontIndex: frontIndex, count: items.count)
                    deckCard(for: item, at: position)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Swipe up or down to browse. Double tap to open.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                frontIndex = RecentsDeckLayout.nextFront(frontIndex, count: items.count)
            case .decrement:
                frontIndex = RecentsDeckLayout.previousFront(frontIndex, count: items.count)
            @unknown default:
                break
            }
        }
        .accessibilityAction {
            if let frontItem {
                onOpen(frontItem)
            }
        }
        .onChange(of: items) {
            frontIndex = 0
            dragOffset = 0
        }
    }

    private var frontItem: Item? {
        items.indices.contains(frontIndex) ? items[frontIndex] : nil
    }

    private var accessibilityLabelText: Text {
        guard let frontItem else { return Text(title) }
        return Text("\(title), \(frontIndex + 1) of \(items.count), \(cardModel(frontItem).title)")
    }

    private func deckCard(for item: Item, at position: Int) -> some View {
        let isFront = position == 0
        // Second card peeks right, third peeks left.
        let peekDirection: CGFloat = position == 1 ? 1 : (position == 2 ? -1 : 0)
        let tilt: Double = reduceMotion ? 0 : (isFront ? Double(dragOffset / 20) : Double(peekDirection) * 4)

        return Button {
            onOpen(item)
        } label: {
            LibraryCardView(model: cardModel(item), isSelected: false)
        }
        .buttonStyle(.plain)
        .containerRelativeFrame(.horizontal) { length, _ in
            length * 0.6
        }
        .scaleEffect(isFront ? 1 : 0.9)
        .visualEffect { content, proxy in
            content.offset(x: proxy.size.width * 0.3 * peekDirection)
        }
        .offset(x: isFront && !reduceMotion ? dragOffset : 0)
        .rotationEffect(.degrees(tilt))
        .zIndex(Double(items.count - position))
        .allowsHitTesting(isFront)
        .simultaneousGesture(isFront ? swipeGesture : nil)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                // Only clearly horizontal drags move the deck, so vertical scrolling keeps working.
                guard !reduceMotion, abs(value.translation.width) > abs(value.translation.height) else { return }
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                let shouldAdvance = isHorizontal && abs(value.predictedEndTranslation.width) > swipeThreshold

                if reduceMotion {
                    if shouldAdvance {
                        frontIndex = RecentsDeckLayout.nextFront(frontIndex, count: items.count)
                    }
                    dragOffset = 0
                } else {
                    withAnimation(.spring(duration: 0.4)) {
                        if shouldAdvance {
                            frontIndex = RecentsDeckLayout.nextFront(frontIndex, count: items.count)
                        }
                        dragOffset = 0
                    }
                }
            }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        RecentsDeckView(
            title: "Last Viewed",
            items: ["Negroni", "Daiquiri", "Martini"],
            cardModel: { LibraryCardModel(title: $0, image: .symbol("wineglass"), imageContentMode: .fit) },
            onOpen: { _ in }
        )
        .padding()
    }
}
#endif
```

Notes for the implementer:
- `ForEach(Array(items.enumerated()), id: \.element)` is used here on purpose. `ForEach` over `enumerated()` without `Array` requires the `RandomAccessCollection` conformance on `EnumeratedSequence`, which is iOS 26-only in Swift 6.2. If the project's Swift toolchain accepts `ForEach(items.enumerated(), id: \.element)`, prefer that form (CLAUDE.md rule) and drop the `Array(...)`. Try it first; fall back only if it doesn't compile.
- `simultaneousGesture(isFront ? swipeGesture : nil)` uses the optional-gesture overload. If it doesn't compile, use `.simultaneousGesture(swipeGesture, including: isFront ? .all : .subviews)`.
- `deckCard(for:at:)` is a helper *function* that returns a view for one `ForEach` element. That's acceptable; the "no computed view properties" rule is about splitting a body into properties. If a reviewer objects, extract a `RecentsDeckCard` struct.

- [ ] **Step 6: Build and check the preview**

Run the iOS build command. Expected: `BUILD SUCCEEDED`. Render the `RecentsDeckView` preview with the Xcode MCP `RenderPreview` tool. Expected: the front card is centered, one card peeks out on each side, and both are tilted.

- [ ] **Step 7: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Views/Library/RecentsDeckLayout.swift DrinkoPro/Views/Library/RecentsDeckView.swift DrinkoProTests/RecentsDeckLayoutTests.swift
git commit -m "Add swipeable recents deck carousel

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: LibraryView

**Files:**
- Create: `DrinkoPro/Views/Library/LibraryView.swift`

**Interfaces:**
- Consumes: `RecentsDeckView`, `LibrarySectionView`, `CollapsedSections`, `LibraryLayout`.
- Produces:
  - `LibraryView<Item: Hashable, MenuContent: View>(recentsTitle:recents:sections:selection:isSearching:collapsedSections:layout:onSelect:cardModel:contextMenu:)`
  - `selection: Item?`, `collapsedSections: Binding<CollapsedSections>`, `onSelect: @MainActor (Item) -> Void`, `cardModel: @MainActor (Item) -> LibraryCardModel`, `contextMenu: @MainActor @ViewBuilder (Item) -> MenuContent`

- [ ] **Step 1: Implement**

```swift
//
//  LibraryView.swift
//  DrinkoPro
//

import SwiftUI

/// The shared sidebar body for Learn and Cocktails: a recents deck followed by collapsible sections.
///
/// Screens own their data, selection and persisted state; this view only renders it.
struct LibraryView<Item: Hashable, MenuContent: View>: View {
    let recentsTitle: String
    let recents: [Item]
    let sections: [LibrarySection<Item>]
    let selection: Item?
    let isSearching: Bool
    @Binding var collapsedSections: CollapsedSections
    let layout: LibraryLayout
    let onSelect: @MainActor (Item) -> Void
    let cardModel: @MainActor (Item) -> LibraryCardModel
    @ViewBuilder let contextMenu: @MainActor (Item) -> MenuContent

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if !isSearching && !recents.isEmpty {
                    RecentsDeckView(
                        title: recentsTitle,
                        items: recents,
                        cardModel: cardModel,
                        onOpen: onSelect
                    )
                }

                ForEach(sections) { section in
                    LibrarySectionView(
                        section: section,
                        layout: layout,
                        isCollapsed: collapsedSections.isCollapsed(section.id, whileSearching: isSearching),
                        isCollapsible: !isSearching,
                        selection: selection,
                        onToggleCollapsed: {
                            withAnimation(.snappy) {
                                collapsedSections.toggle(section.id)
                            }
                        },
                        onSelect: onSelect,
                        cardModel: cardModel,
                        contextMenu: contextMenu
                    )
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .animation(.snappy, value: layout)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var collapsed = CollapsedSections()
    NavigationStack {
        LibraryView(
            recentsTitle: "Last Viewed",
            recents: ["Negroni", "Daiquiri", "Martini"],
            sections: [
                LibrarySection(id: "a", title: "A", items: ["Americano", "Aviation"]),
                LibrarySection(id: "b", title: "B", items: ["Bramble", "Boulevardier", "Bee's Knees"])
            ],
            selection: "Aviation",
            isSearching: false,
            collapsedSections: $collapsed,
            layout: .grid,
            onSelect: { _ in },
            cardModel: { LibraryCardModel(title: $0, image: .symbol("wineglass"), imageContentMode: .fit) },
            contextMenu: { _ in EmptyView() }
        )
        .navigationTitle("Cocktails")
    }
}
#endif
```

- [ ] **Step 2: Build and check the preview**

Run the iOS build command. Expected: `BUILD SUCCEEDED`. Render the preview with `RenderPreview` and check the layout: deck, then section A, then section B, with a 16pt side gutter.

- [ ] **Step 3: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Views/Library/LibraryView.swift
git commit -m "Add generic LibraryView composing deck and sections

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 9: Learn screen on LibraryView

**Files:**
- Rewrite: `DrinkoPro/Views/Learn/LearnView.swift`
- Delete: `DrinkoPro/Views/Learn/Lessons/LessonRowView.swift`, `DrinkoPro/Views/Learn/BookRowView.swift`, `DrinkoPro/Views/Learn/ABV/ABVRowView.swift`, `DrinkoPro/Views/Learn/Superjuice/SuperjuiceRowView.swift`, `DrinkoPro/Views/Learn/Lessons/LearnHeaderView.swift`

**Interfaces:**
- Consumes:
  - `LibraryView`, `LibraryLayoutToggle`, `LibraryLayout.storageKey`, `CollapsedSections`
  - `RecentsStore` (`.learn`)
  - `LessonsViewModel.librarySections(matching:)`, `cardModel(for:)`, `recentItems(from:)`
  - `LearnView.Selection.id`

- [ ] **Step 1: Rewrite `LearnView.swift`**

Keep the file header comment and replace everything else with:

```swift
import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"

    @Environment(LessonsViewModel.self) private var viewModel
    @Environment(RecentsStore.self) private var recentsStore

    @State private var searchText = ""
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    @AppStorage(LibraryLayout.storageKey) private var layout: LibraryLayout = .list
    @AppStorage("learnCollapsedSections") private var collapsedSections = CollapsedSections()

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            Group {
                let sections = viewModel.librarySections(matching: searchText)

                if isSearching && sections.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("\"\(trimmedSearchText)\" not found", systemImage: "exclamationmark.magnifyingglass")
                        },
                        description: {
                            Text("No lessons or books match \"\(trimmedSearchText)\". Try a different search term or browse all topics.")
                        },
                        actions: {
                            Button("Clear Search", systemImage: "xmark.circle") {
                                searchText = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    )
                } else {
                    LibraryView(
                        recentsTitle: String(localized: "Last Read"),
                        recents: viewModel.recentItems(from: recentsStore.ids(in: .learn)),
                        sections: sections,
                        selection: selection,
                        isSearching: isSearching,
                        collapsedSections: $collapsedSections,
                        layout: layout,
                        onSelect: select,
                        cardModel: viewModel.cardModel(for:),
                        contextMenu: { _ in EmptyView() }
                    )
                }
            }
            .navigationTitle("Learn")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search lessons and books")
            .toolbar {
                ToolbarItem {
                    LibraryLayoutToggle(layout: $layout)
                }
            }
            #if os(iOS) || os(macOS)
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
            #endif
        } detail: {
            if let selection {
                LearnDetailView(selection: selection)
                    // Recreate the detail so per-page state (e.g. calculator inputs) resets on a new selection.
                    .id(selection)
            } else {
                ContentUnavailableView(
                    "Select a Topic",
                    systemImage: "books.vertical",
                    description: Text("Choose a lesson, calculator or book to start learning.")
                )
            }
        }
    }

    /// Opens `item` in the detail column, pushing it on compact widths, and records it as recent.
    private func select(_ item: Selection) {
        selection = item
        preferredCompactColumn = .detail
        recentsStore.record(item.id, in: .learn)
    }
}

#if DEBUG
#Preview {
    LearnView()
        .drinkoPreviewEnvironment()
}
#endif
```

The old `@ViewBuilder detailView(for:)` function becomes a small view struct (one type per file). Create `DrinkoPro/Views/Learn/LearnDetailView.swift`:

```swift
//
//  LearnDetailView.swift
//  DrinkoPro
//

import SwiftUI

/// The detail column content for a Learn selection.
struct LearnDetailView: View {
    let selection: LearnView.Selection

    var body: some View {
        switch selection {
        case .lesson(let lesson):
            LessonDetailView(lesson: lesson)
        case .book(let book):
            BookDetailView(book: book)
        case .abvCalculator:
            ABVCalculator()
        case .superjuice(let juiceType):
            SuperJuiceView(typeOfJuice: juiceType)
        }
    }
}
```

- [ ] **Step 2: Delete the replaced views**

```bash
git rm DrinkoPro/Views/Learn/Lessons/LessonRowView.swift DrinkoPro/Views/Learn/BookRowView.swift \
  DrinkoPro/Views/Learn/ABV/ABVRowView.swift DrinkoPro/Views/Learn/Superjuice/SuperjuiceRowView.swift \
  DrinkoPro/Views/Learn/Lessons/LearnHeaderView.swift
grep -rn "LessonRowView\|BookRowView\|ABVRowView\|SuperjuiceRowView\|LearnHeaderView" --include="*.swift" .   # expect no output
```

- [ ] **Step 3: Build iOS and macOS**

Run both build commands. Expected: `BUILD SUCCEEDED` for both. If `cardModel: viewModel.cardModel(for:)` causes an isolation error, use `cardModel: { viewModel.cardModel(for: $0) }`.

- [ ] **Step 4: Run all tests**

```bash
xcodebuild test -project DrinkoPro.xcodeproj -scheme DrinkoPro \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' 2>&1 | grep -E "error:|failed|passed|TEST" | tail -20
```

Expected: `** TEST SUCCEEDED **`.

- [ ] **Step 5: Manual check (iPhone 17 Pro simulator, via the Xcode MCP `RunProject` or Xcode)**

- Learn shows the sections; no deck on a fresh install.
- Tap a lesson. Detail is pushed. Go back: the "Last Read" deck appears with that lesson.
- Tap the **same** lesson again. It pushes again.
- Toggle list/grid in the toolbar. Relaunch the app: the layout is kept.
- Collapse "Books", search "abv": Calculators shows ABV. Clear search: Books is still collapsed.
- Swipe the deck horizontally: the card goes to the back. Vertical scroll over the deck still scrolls.

- [ ] **Step 6: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add -A DrinkoPro/Views/Learn
git commit -m "Rebuild Learn on the shared LibraryView

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 10: Cocktails screen on LibraryView

**Files:**
- Modify: `DrinkoPro/Views/Cocktails/CocktailsView.swift`
- Keep: `DrinkoPro/Views/Cocktails/CocktailRowView.swift` (still used by `LinkedCocktailsView`)

**Interfaces:**
- Consumes:
  - `LibraryView`, `LibraryLayoutToggle`, `CollapsedSections`
  - `RecentsStore` (`.cocktails`)
  - `CocktailsViewModel.librarySections(filterOption:source:isFavorite:)`, `cardModel(for:)`, `recentItems(from:)`

- [ ] **Step 1: State and properties**

In `CocktailsView`:

1. Add these after `@Environment(\.modelContext) private var modelContext`:

```swift
    @Environment(RecentsStore.self) private var recentsStore
```

2. Add these after `@State private var selectedCocktail: Cocktail?`:

```swift
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @AppStorage(LibraryLayout.storageKey) private var layout: LibraryLayout = .list
    @AppStorage("cocktailsCollapsedSections") private var collapsedSections = CollapsedSections()
```

3. Replace the `visibleGroupedCocktails` and `visibleSectionKeys` computed properties with:

```swift
    private var visibleSections: [LibrarySection<Cocktail>] {
        viewModel.librarySections(filterOption: filterOption, source: listSource) { cocktail in
            favorites.contains(cocktail)
        }
    }
```

4. Change `NavigationSplitView {` to `NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {`.

5. In the `.toolbar` `ToolbarItemGroup`, change the contents to:

```swift
                        optionsMenu
                        LibraryLayoutToggle(layout: $layout)
                        addCocktailButton
```

- [ ] **Step 2: Content view**

In `private extension CocktailsView`, replace `contentView` with this version:

```swift
    var contentView: some View {
        Group {
            if shouldShowFilterEmptyState {
                filterEmptyStateView
            } else if !viewModel.searchText.isEmpty && visibleCocktails.isEmpty {
                searchEmptyStateView
            } else {
                LibraryView(
                    recentsTitle: String(localized: "Last Viewed"),
                    recents: viewModel.recentItems(from: recentsStore.ids(in: .cocktails)),
                    sections: visibleSections,
                    selection: selectedCocktail,
                    isSearching: !viewModel.searchText.isEmpty,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    onSelect: select,
                    cardModel: { viewModel.cardModel(for: $0) },
                    contextMenu: { cocktail in
                        FavoriteCocktailButtonView(cocktail: cocktail)
                        if cocktail.id.hasPrefix("user-") {
                            DeleteButtonView(
                                label: "Delete",
                                action: {
                                    cocktailPendingDeletion = cocktail
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                )
            }
        }
        .accessibilityLabel("Filter cocktails")
    }
```

Delete the now-unused `fullListView`, `filteredListView` and `cocktailRow(for:)`.

Add this to the same extension:

```swift
    /// Opens `cocktail` in the detail column, pushing it on compact widths, and records it as recent.
    func select(_ cocktail: Cocktail) {
        selectedCocktail = cocktail
        preferredCompactColumn = .detail
        recentsStore.record(cocktail.id, in: .cocktails)
    }
```

Note on the recents deck vs. the source filter: `recentItems` resolves against `listOfAllDrinks`, so a recent user cocktail still shows in the deck while `listSource == .appOnly`. That's acceptable ("last viewed" is history, not the filtered list). Opening it still works, because the detail view doesn't depend on the list.

- [ ] **Step 3: Deep links**

In `openPendingCocktailIfNeeded()`, replace `selectedCocktail = cocktail` with:

```swift
        select(cocktail)
```

- [ ] **Step 4: Build iOS and macOS, run all tests**

Run both build commands, then the full test command from Task 9 Step 4. Expected: both builds succeed and `** TEST SUCCEEDED **`.

- [ ] **Step 5: Manual check (iPhone 17 Pro simulator)**

- Cocktails shows lettered sections (A, B…). Grid cards show photos with the title only.
- Open a cocktail, go back: the "Last Viewed" deck shows it. Re-tapping the same cocktail pushes again.
- Long-press a card: Add/Remove Favorite works. On a user cocktail, Delete shows the confirmation alert, and confirming removes it from the list **and** the deck.
- Sort by Glass: sections become glass names. The Favorites filter with none set shows the existing empty state.
- Search "neg": grouped results; the deck is hidden.
- The layout chosen here is also applied on the Learn tab (shared key).
- Open a `drinko://` cocktail deep link (or tap a widget) to check that the detail opens and the cocktail appears in the deck.

- [ ] **Step 6: Lint and commit**

```bash
swiftlint lint --quiet | grep " error: "
git add DrinkoPro/Views/Cocktails/CocktailsView.swift
git commit -m "Rebuild Cocktails on the shared LibraryView

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 11: Final verification

**Files:** none, unless fixes are needed.

- [ ] **Step 1: Full test suite.** Run the full test command. Expected: `** TEST SUCCEEDED **`, with every suite from Tasks 1–7 listed.
- [ ] **Step 2: Builds.** iOS and macOS build commands: `BUILD SUCCEEDED`. Also build the widget: `xcodebuild build -project DrinkoPro.xcodeproj -scheme DrinkoWidget -destination 'platform=iOS Simulator,name=iPhone 17 Pro' 2>&1 | grep -E "error:|BUILD"`.
- [ ] **Step 3: Lint.** `swiftlint lint --quiet | grep -c " error: "` gives `0`.
- [ ] **Step 4: iPad and macOS manual check.**
  - iPad simulator: both screens in the split-view sidebar, grid with 2 columns, deck fits the column, selection highlight visible.
  - macOS: run `DrinkoDesktop`, widen the sidebar, and check that the grid adds columns. Right-click a cocktail: context menu.
- [ ] **Step 5: Accessibility manual check.**
  - VoiceOver on the deck reads "Last Read, 1 of 3, <title>". Swipe up cycles, double-tap opens.
  - Turn on Reduce Motion: the deck swaps without tilt or animation.
  - Use the largest Dynamic Type size: rows and cards grow, nothing is clipped.
- [ ] **Step 6: Leftovers.** `grep -rn "basicLessons\|getLessons\|isCollapsed(for:\|visibleGroupedCocktails" --include="*.swift" .` gives no output.
- [ ] **Step 7: Commit any fixes** with a descriptive message and the co-author trailer.
