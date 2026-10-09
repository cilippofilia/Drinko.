# iPad Adaptable Tab Sidebar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give iPad the Apple News navigation pattern: a floating top tab bar that expands into a sidebar with sidebar-only groups (cocktail filters, Learn sections, tools, Cabinet categories), with full-width push-navigation pages instead of per-tab split views.

**Architecture:** `HomeView`'s `TabView` switches to `.sidebarAdaptable` and is driven by a typed `AppTab` enum (replacing `String?` tags). Sidebar-only rows are `Tab`s inside `TabSection`s with `.tabPlacement(.sidebarOnly)`, each hosting an existing page view with a preset (`LearnView(sectionID:)`, `CocktailsView(filter:)`, `CabinetView(categoryID:)`, a tool's detail view). On iOS each page becomes a `NavigationStack`; macOS keeps its `NavigationSplitView`s via `#if os(macOS)`.

**Tech Stack:** Swift 6, SwiftUI (iOS 26 / macOS 26), SwiftData, Swift Testing, xcodebuild, SwiftLint.

**Spec:** `docs/superpowers/specs/2026-10-09-ipad-adaptable-tab-sidebar-design.md`

## Global Constraints

- Target iOS 26 / macOS 26, Swift 6 strict concurrency. `@Observable` classes are `@MainActor`.
- Follow `~/.claude/CLAUDE.md`: `.foregroundStyle`, `Button(_:systemImage:action:)`, two-parameter or zero-parameter `onChange` only, no `AnyView`, no GCD, `Task.sleep(for:)`, no hard-coded padding/spacing, no third-party frameworks.
- macOS (`DrinkoDesktop` scheme, `MacHomeView`) must behave exactly as before. `LearnView`, `CocktailsView`, `ToolsView` are compiled into both targets; `CabinetView` and `HomeView` are iOS-only.
- iPhone must look and behave as today (bottom tab bar, no sidebar groups).
- Do not edit `DrinkoPro.xcodeproj/project.pbxproj`. New files go only in file-system-synchronized folders: `DrinkoPro/Helpers/` (both targets) and `DrinkoProTests/`. If Xcode rewrites the pbxproj with unrelated churn, restore it with `git checkout -- DrinkoPro.xcodeproj/project.pbxproj` before committing. Never quit or script Xcode.
- Every commit message ends with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Commit only the files the task touched (`git add <paths>`, never `git add -A`).
- SwiftLint (`swiftlint lint --quiet`) must report no **errors**, and no new warnings in touched lines.

### Commands (used by every task)

- iOS build: `xcodebuild -project DrinkoPro.xcodeproj -scheme DrinkoPro -destination 'generic/platform=iOS Simulator' build -quiet 2>&1 | grep -E "error:|warning: .*(AppTab|HomeView|LearnView|CocktailsView|ToolsView|CabinetView)" ; echo "exit ${pipestatus[1]}"` → expect `exit 0`, no `error:` lines.
- macOS build: `xcodebuild -project DrinkoPro.xcodeproj -scheme DrinkoDesktop -destination 'platform=macOS' build -quiet 2>&1 | grep -E "error" ; echo "exit ${pipestatus[1]}"` → expect `exit 0`. A known flake prints `error: the following command failed with exit code 0 but produced no further output`; if that is the only error, rerun once.
- Tests: `xcodebuild -project DrinkoPro.xcodeproj -scheme DrinkoPro -destination 'id=3447C73E-6AE8-4D2B-B533-0DECF75B7361' test -quiet 2>&1 | grep -E "error:|failed|✘" | head -30; echo "exit ${pipestatus[1]}"` → expect `exit 0`. Add `-only-testing:DrinkoProTests/AppTabTests` to run one suite.
- Lint: `swiftlint lint --quiet 2>/dev/null | grep -E "error|<touched file names>"`.

## Review Focus

1. **A tab saved by the previous app version** (`"Learn"`, `"Cocktails"`, …) must still restore → Task 2 test `legacyTagsDecodeToMainTabs`.
2. **A saved sidebar tab that no longer exists** (deleted Cabinet category, removed topic, unknown tool) must land on its main tab, not a blank page → Task 2 tests `staleDetailsDecodeToParent`, Task 8 test `fittedDropsDeletedCategory`.
3. **iPad window narrowed to compact (Split View) while a sidebar-only tab is selected** must fall back to its main tab in the bottom bar → Task 3 test `fittedUsesParentWhenCompact`.
4. **Cocktail deep link while a cocktail filter page has been opened before** must open the cocktail on the main Cocktails page, not be swallowed by the filter page → Task 5 Step "deep link guard" + manual check.
5. **A preset filter page whose list is empty** (Shots with the "My cocktails only" list source, Favorites with none) must show an explanatory empty state, not a blank page → Task 5 empty-state step + manual check.

---

### Task 1: Remove the uncommitted iPad split-view work, keep the recents delay

**Files:**
- Restore from `HEAD`: `DrinkoPro/Helpers/CrossPromoBannerModifier.swift`, `DrinkoPro/Views/Cabinet/CabinetView.swift`, `DrinkoPro/Views/Cocktails/CocktailsView.swift`, `DrinkoPro/Views/Learn/LearnView.swift`, `DrinkoPro/Views/Library/CollapsedSections.swift`, `DrinkoPro/Views/Library/RecentsDeckCard.swift`, `DrinkoPro/Views/Library/RecentsDeckLayout.swift`, `DrinkoPro/Views/Library/RecentsDeckView.swift`, `DrinkoPro/Views/Tools/ToolsView.swift`
- Delete: `DrinkoPro/Views/Library/LibrarySidebarList.swift`, `DrinkoPro/Views/Library/RecentsDetailEmptyState.swift`
- Keep (commit): `DrinkoPro/Views/Library/RecentsStore.swift` (`recordDelay`)

**Interfaces:**
- Produces: `RecentsStore.recordDelay: Duration` (`.seconds(1)`), used by Tasks 4 and 5.

- [ ] **Step 1: Back up the work being removed**

```bash
git diff > /private/tmp/claude-501/-Users-filippocilia-Desktop-Projects-iOS-Drinko/3e931ade-17a0-4bd4-a5fa-1d04be395c81/scratchpad/ipad-split-view-work.patch
cp DrinkoPro/Views/Library/LibrarySidebarList.swift DrinkoPro/Views/Library/RecentsDetailEmptyState.swift /private/tmp/claude-501/-Users-filippocilia-Desktop-Projects-iOS-Drinko/3e931ade-17a0-4bd4-a5fa-1d04be395c81/scratchpad/
```

- [ ] **Step 2: Restore and delete**

```bash
git checkout HEAD -- DrinkoPro/Helpers/CrossPromoBannerModifier.swift DrinkoPro/Views/Cabinet/CabinetView.swift DrinkoPro/Views/Cocktails/CocktailsView.swift DrinkoPro/Views/Learn/LearnView.swift DrinkoPro/Views/Library/CollapsedSections.swift DrinkoPro/Views/Library/RecentsDeckCard.swift DrinkoPro/Views/Library/RecentsDeckLayout.swift DrinkoPro/Views/Library/RecentsDeckView.swift DrinkoPro/Views/Tools/ToolsView.swift
rm DrinkoPro/Views/Library/LibrarySidebarList.swift DrinkoPro/Views/Library/RecentsDetailEmptyState.swift
git status --short
```

Expected `git status --short`: only ` M DrinkoPro/Views/Library/RecentsStore.swift`.

- [ ] **Step 3: Verify `RecentsStore` still has the delay**

`DrinkoPro/Views/Library/RecentsStore.swift` must contain, right after `static let capacity = 9`:

```swift
    /// How long a selection must stay put before it's recorded, so arrowing through a
    /// sidebar list with a hardware keyboard doesn't record every row it passes.
    static let recordDelay: Duration = .seconds(1)
```

- [ ] **Step 4: Build both targets** (commands above). Expected: both `exit 0`.

- [ ] **Step 5: Commit**

```bash
git add DrinkoPro/Views/Library/RecentsStore.swift
git commit -m "Add a settle delay for recording recents

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: `AppTab` and its string encoding

**Files:**
- Create: `DrinkoPro/Helpers/AppTab.swift`
- Modify: `DrinkoPro/Models/Cocktails/Cocktail.swift` (the `FilterOption` enum near line 447)
- Modify: `DrinkoPro/Views/Tools/ToolsView+Selection.swift`
- Modify: `DrinkoPro/Models/Learn/LessonsViewModel+Library.swift`
- Test: `DrinkoProTests/AppTabTests.swift` (create)

**Interfaces:**
- Produces:
  - `enum AppTab: Hashable, RawRepresentable` with cases `.learn`, `.learnSection(String)`, `.cabinet`, `.cabinetCategory(UUID)`, `.cocktails`, `.cocktailFilter(CocktailsViewModel.FilterOption)`, `.tools`, `.tool(ToolsView.Selection)`, `.settings`; `var parent: AppTab`; `var isSidebarOnly: Bool`; `static let sidebarCocktailFilters: [CocktailsViewModel.FilterOption]`.
  - `CocktailsViewModel.FilterOption: String` (raw values = case names); `var pageTitle: String`; `var sidebarSymbol: String`.
  - `ToolsView.Selection.init?(id: String)`.
  - `LessonsViewModel.sectionTitle(for id: String) -> String?` (static); `LessonsViewModel.librarySectionIDs: [String]` (static).

- [ ] **Step 1: Write the failing tests** — create `DrinkoProTests/AppTabTests.swift`:

```swift
//
//  AppTabTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@MainActor
@Suite("AppTab")
struct AppTabTests {
    private let categoryID = UUID()

    private var everyTab: [AppTab] {
        [
            .learn, .learnSection("bar-preps"), .learnSection(LessonsViewModel.booksSectionID),
            .cabinet, .cabinetCategory(categoryID),
            .cocktails, .cocktailFilter(.shotsOnly), .cocktailFilter(.favoritesOnly), .cocktailFilter(.userCreatedOnly),
            .tools, .tool(.abvCalculator), .tool(.superjuice("lime")),
            .settings
        ]
    }

    @Test func rawValueRoundTrips() {
        for tab in everyTab {
            #expect(AppTab(rawValue: tab.rawValue) == tab, "\(tab.rawValue)")
        }
    }

    @Test func legacyTagsDecodeToMainTabs() {
        #expect(AppTab(rawValue: "Learn") == .learn)
        #expect(AppTab(rawValue: "Cabinet") == .cabinet)
        #expect(AppTab(rawValue: "Cocktails") == .cocktails)
        #expect(AppTab(rawValue: "Tools") == .tools)
        #expect(AppTab(rawValue: "Settings") == .settings)
    }

    @Test func staleDetailsDecodeToParent() {
        #expect(AppTab(rawValue: "Learn/not-a-topic") == .learn)
        #expect(AppTab(rawValue: "Cabinet/not-a-uuid") == .cabinet)
        #expect(AppTab(rawValue: "Cocktails/notAFilter") == .cocktails)
        #expect(AppTab(rawValue: "Tools/superjuice:grape") == .tools)
    }

    @Test func unknownNamesDecodeToNil() {
        #expect(AppTab(rawValue: "") == nil)
        #expect(AppTab(rawValue: "MacCabinet") == nil)
        #expect(AppTab(rawValue: "learn") == nil)
    }

    @Test func parentAndSidebarOnly() {
        #expect(AppTab.learnSection("bar-preps").parent == .learn)
        #expect(AppTab.cabinetCategory(categoryID).parent == .cabinet)
        #expect(AppTab.cocktailFilter(.shotsOnly).parent == .cocktails)
        #expect(AppTab.tool(.abvCalculator).parent == .tools)
        for main in [AppTab.learn, .cabinet, .cocktails, .tools, .settings] {
            #expect(main.parent == main)
            #expect(!main.isSidebarOnly)
        }
        #expect(AppTab.tool(.abvCalculator).isSidebarOnly)
    }

    @Test func sidebarCocktailFiltersAreShotsFavoritesMine() {
        #expect(AppTab.sidebarCocktailFilters == [.shotsOnly, .favoritesOnly, .userCreatedOnly])
    }

    @Test func toolSelectionDecodesOnlyRealTools() {
        #expect(ToolsView.Selection(id: "abv") == .abvCalculator)
        #expect(ToolsView.Selection(id: "superjuice:lemon") == .superjuice("lemon"))
        #expect(ToolsView.Selection(id: "superjuice:grape") == nil)
        #expect(ToolsView.Selection(id: "") == nil)
    }

    @Test func learnSectionTitles() {
        #expect(LessonsViewModel.sectionTitle(for: "bar-preps") == String(localized: "Bar Preps"))
        #expect(LessonsViewModel.sectionTitle(for: LessonsViewModel.booksSectionID) == String(localized: "Books"))
        #expect(LessonsViewModel.sectionTitle(for: "nope") == nil)
        #expect(LessonsViewModel.librarySectionIDs == LearnTopic.all.map(\.id) + [LessonsViewModel.booksSectionID])
    }
}
```

- [ ] **Step 2: Run to verify it fails** — Tests command with `-only-testing:DrinkoProTests/AppTabTests`. Expected: build error `cannot find 'AppTab' in scope`.

- [ ] **Step 3: Make `FilterOption` string-backed and titled** — in `DrinkoPro/Models/Cocktails/Cocktail.swift` replace

```swift
extension CocktailsViewModel {
    enum FilterOption {
```

with

```swift
extension CocktailsViewModel {
    /// Raw values are persisted (as part of `AppTab`'s raw value), so don't rename cases.
    enum FilterOption: String {
```

and add right after that extension's closing brace:

```swift
extension CocktailsViewModel.FilterOption {
    /// The page title when this filter is a page's preset (the iPad sidebar rows).
    var pageTitle: String {
        switch self {
        case .all, .cocktailsOnly: String(localized: "Cocktails")
        case .shotsOnly: String(localized: "Shots")
        case .favoritesOnly: String(localized: "Favorites")
        case .userCreatedOnly: String(localized: "My Cocktails")
        }
    }

    /// The SF Symbol for this filter's iPad sidebar row.
    var sidebarSymbol: String {
        switch self {
        case .all, .cocktailsOnly: "wineglass"
        case .shotsOnly: "drop"
        case .favoritesOnly: "heart"
        case .userCreatedOnly: "person.crop.circle"
        }
    }
}
```

- [ ] **Step 4: Add `ToolsView.Selection.init?(id:)`** — in `DrinkoPro/Views/Tools/ToolsView+Selection.swift`, inside `enum Selection`, after `var id`:

```swift
        /// The tool whose `id` is `id`, or `nil` when no current tool has that ID.
        init?(id: String) {
            guard let match = ToolsLibrary.calculatorItems.first(where: { $0.id == id }) else { return nil }
            self = match
        }
```

- [ ] **Step 5: Add Learn section helpers** — in `DrinkoPro/Models/Learn/LessonsViewModel+Library.swift`, after `static let booksSectionID = "books"`:

```swift
    /// Every library section ID in display order: the topics, then Books.
    static var librarySectionIDs: [String] {
        LearnTopic.all.map(\.id) + [booksSectionID]
    }

    /// The display title of the library section `id`, or `nil` when there's no such section.
    static func sectionTitle(for id: String) -> String? {
        if id == booksSectionID {
            return String(localized: "Books")
        }
        return LearnTopic.all.first { $0.id == id }?.title
    }
```

- [ ] **Step 6: Create `DrinkoPro/Helpers/AppTab.swift`**

```swift
//
//  AppTab.swift
//  DrinkoPro
//

import Foundation

/// Every destination the iOS tab view can select: the five main tabs, plus the iPad
/// sidebar-only rows that open a main tab's page with a preset.
enum AppTab: Hashable {
    case learn
    /// A Learn page showing one library section (a `LearnTopic.id` or `LessonsViewModel.booksSectionID`).
    case learnSection(String)
    case cabinet
    /// A Cabinet page showing one category (`Category.id`).
    case cabinetCategory(UUID)
    case cocktails
    /// A Cocktails page with a fixed filter.
    case cocktailFilter(CocktailsViewModel.FilterOption)
    case tools
    /// One tool, opened directly.
    case tool(ToolsView.Selection)
    case settings

    /// The cocktail filters that get their own sidebar row, in display order.
    static let sidebarCocktailFilters: [CocktailsViewModel.FilterOption] = [.shotsOnly, .favoritesOnly, .userCreatedOnly]

    /// The main tab this destination belongs to; a main tab is its own parent.
    var parent: AppTab {
        switch self {
        case .learn, .learnSection: .learn
        case .cabinet, .cabinetCategory: .cabinet
        case .cocktails, .cocktailFilter: .cocktails
        case .tools, .tool: .tools
        case .settings: .settings
        }
    }

    /// Whether this destination only exists in the iPad sidebar (not in the tab bar).
    var isSidebarOnly: Bool {
        self != parent
    }
}

extension AppTab: RawRepresentable {
    /// Main tabs keep the strings the old `String?` tab tags used, so a tab saved by an
    /// earlier version still restores. Sidebar rows append `/<detail>`.
    private enum Name: String {
        case learn = "Learn"
        case cabinet = "Cabinet"
        case cocktails = "Cocktails"
        case tools = "Tools"
        case settings = "Settings"
    }

    /// Decodes a saved tab. A detail that no longer exists (a deleted topic, an unknown
    /// tool or filter, a malformed category ID) decodes to the main tab instead.
    init?(rawValue: String) {
        let parts = rawValue.split(separator: "/", maxSplits: 1).map(String.init)
        guard let first = parts.first, let name = Name(rawValue: first) else { return nil }
        let detail = parts.count > 1 ? parts[1] : nil

        switch name {
        case .learn:
            if let detail, LessonsViewModel.sectionTitle(for: detail) != nil {
                self = .learnSection(detail)
            } else {
                self = .learn
            }
        case .cabinet:
            self = detail.flatMap(UUID.init(uuidString:)).map(AppTab.cabinetCategory) ?? .cabinet
        case .cocktails:
            self = detail.flatMap(CocktailsViewModel.FilterOption.init(rawValue:)).map(AppTab.cocktailFilter) ?? .cocktails
        case .tools:
            self = detail.flatMap(ToolsView.Selection.init(id:)).map(AppTab.tool) ?? .tools
        case .settings:
            self = .settings
        }
    }

    var rawValue: String {
        switch self {
        case .learn: Name.learn.rawValue
        case .learnSection(let id): "\(Name.learn.rawValue)/\(id)"
        case .cabinet: Name.cabinet.rawValue
        case .cabinetCategory(let id): "\(Name.cabinet.rawValue)/\(id.uuidString)"
        case .cocktails: Name.cocktails.rawValue
        case .cocktailFilter(let filter): "\(Name.cocktails.rawValue)/\(filter.rawValue)"
        case .tools: Name.tools.rawValue
        case .tool(let selection): "\(Name.tools.rawValue)/\(selection.id)"
        case .settings: Name.settings.rawValue
        }
    }
}
```

Equality and hashing must stay the synthesized, case-based ones (not raw-value based). If the compiler reports an ambiguous `==` between the synthesized `Equatable` and the standard library's `RawRepresentable` overload, stop and report it rather than working around it.

- [ ] **Step 7: Run the suite** — Tests command with `-only-testing:DrinkoProTests/AppTabTests`. Expected: `exit 0`, all 8 tests pass.

- [ ] **Step 8: Build macOS** — macOS build command. Expected `exit 0` (`AppTab.swift` compiles into `DrinkoDesktop` via the synced Helpers folder; it only references types already in that target).

- [ ] **Step 9: Commit**

```bash
git add DrinkoPro/Helpers/AppTab.swift DrinkoProTests/AppTabTests.swift DrinkoPro/Models/Cocktails/Cocktail.swift DrinkoPro/Views/Tools/ToolsView+Selection.swift DrinkoPro/Models/Learn/LessonsViewModel+Library.swift
git commit -m "Add AppTab, a typed tab selection with a stable string encoding

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Drive `HomeView` with `AppTab` and the adaptable tab style

**Files:**
- Modify: `DrinkoPro/Helpers/AppNavigationModel.swift`
- Modify: `DrinkoPro/Helpers/AppTab.swift` (add `fitted`)
- Modify: `DrinkoPro/HomeView.swift`
- Modify (delete the tag constants): `DrinkoPro/Views/Learn/LearnView.swift` (`learnTag`), `DrinkoPro/Views/Cabinet/CabinetView.swift` (`cabinetTag`), `DrinkoPro/Views/Cocktails/CocktailsView.swift` (`cocktailsTag`), `DrinkoPro/Views/Tools/ToolsView.swift` (`toolsTag`), `DrinkoPro/Views/Settings/SettingsView.swift` (`settingsTag`). Do **not** touch `DrinkoMac/**` tags.
- Test: `DrinkoProTests/AppTabTests.swift`

**Interfaces:**
- Consumes: `AppTab` (Task 2).
- Produces: `AppNavigationModel.selectedTab: AppTab` (non-optional, default `.learn`); `AppTab.fitted(isCompact: Bool, categoryIDs: Set<UUID>) -> AppTab`.

- [ ] **Step 1: Write failing tests** — append to `AppTabTests`:

```swift
    @Test func fittedUsesParentWhenCompact() {
        let tab = AppTab.cocktailFilter(.shotsOnly)
        #expect(tab.fitted(isCompact: true, categoryIDs: []) == .cocktails)
        #expect(tab.fitted(isCompact: false, categoryIDs: []) == tab)
        #expect(AppTab.settings.fitted(isCompact: true, categoryIDs: []) == .settings)
    }

    @Test func fittedDropsDeletedCategory() {
        let tab = AppTab.cabinetCategory(categoryID)
        #expect(tab.fitted(isCompact: false, categoryIDs: [categoryID]) == tab)
        #expect(tab.fitted(isCompact: false, categoryIDs: [UUID()]) == .cabinet)
    }

    @Test func deepLinkSelectsCocktails() throws {
        let model = AppNavigationModel()
        model.handle(url: try #require(URL(string: "drinko://cocktail/negroni")))
        #expect(model.selectedTab == .cocktails)
        #expect(model.consumePendingCocktailID() == "negroni")

        let untouched = AppNavigationModel()
        untouched.handle(url: try #require(URL(string: "https://cocktail/negroni")))
        #expect(untouched.selectedTab == .learn)
    }
```

- [ ] **Step 2: Run** `-only-testing:DrinkoProTests/AppTabTests`. Expected: build error (`fitted` missing, `selectedTab` type mismatch).

- [ ] **Step 3: Add `fitted`** — inside `enum AppTab` in `AppTab.swift`, after `isSidebarOnly`:

```swift
    /// This destination adjusted to what can currently be shown: sidebar-only rows fall back
    /// to their main tab in a compact (bottom tab bar) layout, and a Cabinet category that
    /// no longer exists falls back to Cabinet.
    func fitted(isCompact: Bool, categoryIDs: Set<UUID>) -> AppTab {
        if isCompact {
            return parent
        }
        if case .cabinetCategory(let id) = self, !categoryIDs.contains(id) {
            return .cabinet
        }
        return self
    }
```

- [ ] **Step 4: Retype `AppNavigationModel`** — in `DrinkoPro/Helpers/AppNavigationModel.swift`:
  - `var selectedTab: String? = LearnView.learnTag` → `var selectedTab: AppTab = .learn`
  - `selectedTab = CocktailsView.cocktailsTag` → `selectedTab = .cocktails`

- [ ] **Step 5: Delete the five iOS tag constants** listed under Files (each is a single `static let …Tag: String? = "…"` line, plus the blank line after it if one is left dangling).

- [ ] **Step 6: Update `HomeView`** (`DrinkoPro/HomeView.swift`):
  - Add `@Environment(\.horizontalSizeClass) private var horizontalSizeClass` after the other `@Environment` lines.
  - Replace the `TabView { … }` contents and the `.tabViewStyle`/restore/`onChange(of: selectedTab)` modifiers with:

```swift
        TabView(selection: $appNavigationModel.selectedTab) {
            Tab("Learn", systemImage: "books.vertical", value: AppTab.learn) {
                LearnView()
            }
            Tab("Cabinet", systemImage: "cabinet", value: AppTab.cabinet) {
                CabinetView()
            }
            Tab("Cocktails", systemImage: "wineglass", value: AppTab.cocktails) {
                CocktailsView()
            }
            Tab("Tools", systemImage: "wrench.and.screwdriver", value: AppTab.tools) {
                ToolsView()
            }
            Tab("Settings", systemImage: "gear", value: AppTab.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear(perform: checkForReview)
        // Restore the last-used tab from the previous session. Only applies while
        // `selectedTab` is still at its untouched default, so it never clobbers a deep link
        // (`AppNavigationModel.handle(url:)`) that already selected a tab before this view
        // first appeared.
        .onAppear {
            if appNavigationModel.selectedTab == .learn, let selectedView, let tab = AppTab(rawValue: selectedView) {
                appNavigationModel.selectedTab = tab
            }
            fitSelection()
        }
        .onChange(of: appNavigationModel.selectedTab) { _, newValue in
            selectedView = newValue.rawValue
        }
        .onChange(of: horizontalSizeClass) {
            fitSelection()
        }
```

  - Add this method below `refreshInterstitialAd()`:

```swift
    /// Moves the selection to something the current layout can show (see `AppTab.fitted`).
    private func fitSelection() {
        let fitted = appNavigationModel.selectedTab.fitted(
            isCompact: horizontalSizeClass == .compact,
            categoryIDs: []
        )
        if fitted != appNavigationModel.selectedTab {
            appNavigationModel.selectedTab = fitted
        }
    }
```

  (Task 8 replaces `categoryIDs: []` with the real IDs. With no Cabinet category rows yet, `.cabinetCategory` can't be selected, so an empty set is correct here.)
  - In the `#Preview`, delete the `.tabViewStyle(.tabBarOnly)` line.

- [ ] **Step 7: Run tests** (full suite). Expected `exit 0`.
- [ ] **Step 8: Build iOS and macOS.** Expected `exit 0` both.
- [ ] **Step 9: Commit**

```bash
git add DrinkoPro/Helpers/AppTab.swift DrinkoPro/Helpers/AppNavigationModel.swift DrinkoPro/HomeView.swift DrinkoPro/Views/Learn/LearnView.swift DrinkoPro/Views/Cabinet/CabinetView.swift DrinkoPro/Views/Cocktails/CocktailsView.swift DrinkoPro/Views/Tools/ToolsView.swift DrinkoPro/Views/Settings/SettingsView.swift DrinkoProTests/AppTabTests.swift
git commit -m "Select tabs with AppTab and use the sidebar-adaptable tab style

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Learn — stack navigation on iOS and a section preset

**Files:**
- Modify: `DrinkoPro/Views/Learn/LearnView.swift`

**Interfaces:**
- Consumes: `RecentsStore.recordDelay` (Task 1), `LessonsViewModel.sectionTitle(for:)` (Task 2).
- Produces: `LearnView.init(sectionID: String? = nil)`.

The shared library content moves into a `library` computed property, matching how `CocktailsView` already uses `contentView` (a full `View` struct would need most of this view's state passed in). The platform split is only the container.

- [ ] **Step 1: Replace the struct body** of `LearnView` (everything from `@Environment(LessonsViewModel.self)` down to the end of `select(_:)`; keep the file header, `import SwiftUI` and the `#Preview`) with:

```swift
    @Environment(LessonsViewModel.self) private var viewModel
    @Environment(RecentsStore.self) private var recentsStore

    /// When set, the page shows only this library section (an iPad sidebar row) and hides the
    /// recents deck. `nil` shows the whole library.
    private let sectionID: String?

    @State private var searchText = ""
    #if os(iOS)
    @State private var path: [Selection] = []
    #else
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif

    @AppStorage(LibraryLayout.learnStorageKey) private var layout: LibraryLayout = .initial()
    @AppStorage("learnCollapsedSections") private var collapsedSections = CollapsedSections()

    init(sectionID: String? = nil) {
        self.sectionID = sectionID
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    private var title: String {
        sectionID.flatMap(LessonsViewModel.sectionTitle(for:)) ?? String(localized: "Learn")
    }

    /// The item shown (iOS: the first pushed page; macOS: the detail column).
    private var currentSelection: Selection? {
        #if os(iOS)
        path.first
        #else
        selection
        #endif
    }

    private var layoutTogglePlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .automatic
        #endif
    }

    var body: some View {
        container
            .task(id: currentSelection) {
                // Record only once the selection settles; a new selection cancels this.
                guard let currentSelection else { return }
                try? await Task.sleep(for: RecentsStore.recordDelay)
                guard !Task.isCancelled else { return }
                recentsStore.record(currentSelection.id, in: .learn)
            }
    }

    @ViewBuilder
    private var container: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            library
                .navigationDestination(for: Selection.self) { item in
                    LearnDetailView(selection: item)
                }
        }
        #else
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            library
        } detail: {
            NavigationStack {
                if let selection {
                    LearnDetailView(selection: selection)
                } else {
                    ContentUnavailableView(
                        "Select a Topic",
                        systemImage: "books.vertical",
                        description: Text("Choose a lesson or book to start learning.")
                    )
                }
            }
            // Recreate the detail so per-page state resets on a new selection.
            .id(selection)
        }
        #endif
    }

    private var library: some View {
        Group {
            let sections = viewModel.librarySections(matching: searchText)
                .filter { sectionID == nil || $0.id == sectionID }

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
                    recents: sectionID == nil ? viewModel.recentItems(from: recentsStore.ids(in: .learn)) : [],
                    sections: sections,
                    selection: currentSelection,
                    isSearching: isSearching,
                    collapsedSections: $collapsedSections,
                    layout: layout,
                    showsSectionHeaders: sectionID == nil,
                    onSelect: select,
                    cardModel: viewModel.cardModel(for:),
                    contextMenu: { _ in EmptyView() }
                )
            }
        }
        .navigationTitle(title)
        .searchable(text: $searchText, placement: .automatic, prompt: "Search lessons and books")
        .toolbar {
            ToolbarItem(placement: layoutTogglePlacement) {
                LibraryLayoutToggle(layout: $layout)
            }
        }
        #if os(iOS) || os(macOS)
        .crossPromoBanner()
        #endif
    }

    /// Opens `item`: pushes it on iOS, shows it in the detail column on macOS. It's recorded
    /// as recent once the selection settles (see the `.task(id:)` in `body`).
    private func select(_ item: Selection) {
        #if os(iOS)
        path = [item]
        #else
        selection = item
        preferredCompactColumn = .detail
        #endif
    }
```

Before replacing, compare with the `HEAD` version (`git show HEAD:DrinkoPro/Views/Learn/LearnView.swift`) and carry over any modifier this block omits; the block is written to match it plus the changes above.

- [ ] **Step 2: Build iOS and macOS.** Expected `exit 0` both.
- [ ] **Step 3: Run the full test suite.** Expected `exit 0` (`LearnLibraryTests`, `LessonsViewModelTests` unaffected).
- [ ] **Step 4: Commit**

```bash
git add DrinkoPro/Views/Learn/LearnView.swift
git commit -m "Push Learn pages on iOS and add a single-section preset

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Cocktails — stack navigation on iOS and a filter preset

**Files:**
- Modify: `DrinkoPro/Views/Cocktails/CocktailsView.swift`

**Interfaces:**
- Consumes: `RecentsStore.recordDelay`, `FilterOption.pageTitle` (Task 2).
- Produces: `CocktailsView.init(filter: CocktailsViewModel.FilterOption? = nil)`.

Edits are against the `HEAD` version restored in Task 1 (minus `cocktailsTag`, removed in Task 3).

- [ ] **Step 1: State and init.** Replace

```swift
    @State private var filterOption: CocktailsViewModel.FilterOption = .all
```

with

```swift
    /// A fixed filter for this page (an iPad sidebar row). `nil` lets the user pick one.
    private let presetFilter: CocktailsViewModel.FilterOption?
    @State private var filterOption: CocktailsViewModel.FilterOption
```

and replace

```swift
    @State private var selectedCocktail: Cocktail?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
```

with

```swift
    #if os(iOS)
    @State private var path: [Cocktail] = []
    #else
    @State private var selectedCocktail: Cocktail?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif
```

Add after the `@AppStorage("cocktailsCollapsedSections")` line:

```swift
    init(filter: CocktailsViewModel.FilterOption? = nil) {
        presetFilter = filter
        _filterOption = State(initialValue: filter ?? .all)
    }

    /// The cocktail opened from this page (iOS: the first pushed page, not "You may also like"
    /// pages pushed after it; macOS: the detail column).
    private var currentCocktail: Cocktail? {
        #if os(iOS)
        path.first
        #else
        selectedCocktail
        #endif
    }

    private var title: String {
        presetFilter?.pageTitle ?? String(localized: "Cocktails")
    }
```

- [ ] **Step 2: Body.** Replace the whole `var body: some View { … }` with:

```swift
    var body: some View {
        container
            .task(id: currentCocktail?.id) {
                // Record only once the selection settles; a new selection cancels this.
                guard let id = currentCocktail?.id else { return }
                try? await Task.sleep(for: RecentsStore.recordDelay)
                guard !Task.isCancelled else { return }
                recentsStore.record(id, in: .cocktails)
            }
    }

    @ViewBuilder
    private var container: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            library
                .navigationDestination(for: Cocktail.self) { cocktail in
                    CocktailDetailView(cocktail: cocktail)
                }
        }
        #else
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            library
        } detail: {
            if let selectedCocktail {
                NavigationStack {
                    CocktailDetailView(cocktail: selectedCocktail)
                        .navigationDestination(for: Cocktail.self) { cocktail in
                            CocktailDetailView(cocktail: cocktail)
                        }
                }
                // Reset pushed "You may also like" pages when the sidebar selection changes.
                .id(selectedCocktail.id)
            } else {
                NavigationStack {
                    ContentUnavailableView(
                        "Select a Cocktail",
                        systemImage: "wineglass",
                        description: Text("Choose a cocktail to see its details.")
                    )
                }
            }
        }
        #endif
    }
```

- [ ] **Step 3: `library`.** Add to the `private extension CocktailsView` (above `contentView`) a `library` property holding everything that was chained on `contentView` inside the old sidebar closure, with these changes:
  - `.navigationTitle("Cocktails")` → `.navigationTitle(title)`
  - In `.alert`'s delete action replace

```swift
                            if selectedCocktail == cocktailPendingDeletion {
                                selectedCocktail = nil
                                preferredCompactColumn = .sidebar
                            }
```

    with

```swift
                            clearSelection(after: cocktailPendingDeletion)
```

  - In `.onChange(of: listSource)` replace the body with:

```swift
                    // Drop a filter or selection the new source can no longer show. A preset
                    // filter stays, and its page shows an empty state instead.
                    if presetFilter == nil, !availableFilterOptions.contains(filterOption) {
                        filterOption = .all
                    }
                    if let currentCocktail, !visibleCocktails.contains(currentCocktail) {
                        clearSelection(after: currentCocktail)
                    }
```

  - Keep `.searchable`, `.toolbar`, `.sheet`, `.task`, `.onChange(of: appNavigationModel.pendingCocktailID…)` and `.crossPromoBanner()` exactly as in `HEAD`.

```swift
    var library: some View {
        @Bindable var viewModel = viewModel

        return contentView
            .navigationTitle(title)
            // … the HEAD modifier chain with the changes above …
    }
```

- [ ] **Step 4: Hide the filter picker on preset pages.** In `optionsMenu`, wrap `CocktailFilterSection(…)` in `if presetFilter == nil { … }`.

- [ ] **Step 5: Empty states for preset pages.** Replace `shouldShowFilterEmptyState` with:

```swift
    func shouldShowFilterEmptyState(_ sections: [LibrarySection<Cocktail>]) -> Bool {
        (filterOption == .favoritesOnly || filterOption == .shotsOnly || showsOnlyUserCocktails) && sections.isEmpty
    }
```

In `filterEmptyStateView`:
  - label: before the final `else`, add

```swift
                } else if filterOption == .shotsOnly && viewModel.searchText.isEmpty {
                    Label("No shots to show", systemImage: "drop")
```

  - description: before the final `else`, add

```swift
                } else if filterOption == .shotsOnly && viewModel.searchText.isEmpty {
                    Text("Your list source doesn't include Drinko's shots.")
```

  - actions: change `if filterOption == .userCreatedOnly || filterOption == .favoritesOnly {` to `if presetFilter == nil, filterOption == .userCreatedOnly || filterOption == .favoritesOnly {`.

- [ ] **Step 6: Deep link guard, select, clear.** Replace `openPendingCocktailIfNeeded()` and `select(_:)` with:

```swift
    @MainActor
    func openPendingCocktailIfNeeded() {
        // Only the main Cocktails page opens deep links; a sidebar filter page that has been
        // opened before stays loaded and must not consume the link.
        guard presetFilter == nil else { return }
        guard let cocktailID = appNavigationModel.consumePendingCocktailID() else { return }
        guard let cocktail = viewModel.listOfAllDrinks.first(where: { $0.id == cocktailID }) else { return }

        select(cocktail)
    }

    /// Opens `cocktail`: pushes it on iOS, shows it in the detail column on macOS. It's
    /// recorded as recent once the selection settles (see the `.task(id:)` in `body`).
    func select(_ cocktail: Cocktail) {
        #if os(iOS)
        path = [cocktail]
        #else
        selectedCocktail = cocktail
        preferredCompactColumn = .detail
        #endif
    }

    /// Stops showing `cocktail` once it's gone (deleted, or hidden by the list source):
    /// pops it and anything pushed after it on iOS, clears the detail column on macOS.
    func clearSelection(after cocktail: Cocktail) {
        #if os(iOS)
        if let index = path.firstIndex(of: cocktail) {
            path.removeSubrange(index...)
        }
        #else
        if selectedCocktail == cocktail {
            selectedCocktail = nil
            preferredCompactColumn = .sidebar
        }
        #endif
    }
```

  In `contentView`, the `LibraryView(selection: selectedCocktail, …)` argument becomes `selection: currentCocktail`.

- [ ] **Step 7: Build iOS and macOS; run the full test suite.** Expected `exit 0` for all.
- [ ] **Step 8: Commit**

```bash
git add DrinkoPro/Views/Cocktails/CocktailsView.swift
git commit -m "Push Cocktails pages on iOS and add a filter preset

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Tools — stack navigation on iOS

**Files:**
- Modify: `DrinkoPro/Views/Tools/ToolsView.swift`

**Interfaces:**
- Produces: nothing new; `ToolsDetailView(selection:)` (existing) is reused by Task 8 for `.tool` rows.

- [ ] **Step 1: Replace the struct body** (keep header, import, preview) with:

```swift
    #if os(iOS)
    @State private var path: [Selection] = []
    #else
    @State private var selection: Selection?
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    #endif

    var body: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            library
                .navigationDestination(for: Selection.self) { item in
                    ToolsDetailView(selection: item)
                }
        }
        #else
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            library
        } detail: {
            NavigationStack {
                if let selection {
                    ToolsDetailView(selection: selection)
                } else {
                    ContentUnavailableView(
                        "Select a Tool",
                        systemImage: "wrench.and.screwdriver",
                        description: Text("Choose a calculator to get started.")
                    )
                }
            }
            // Recreate the detail so calculator inputs reset on a new selection.
            .id(selection)
        }
        #endif
    }

    private var library: some View {
        LibraryView(
            recentsTitle: "",
            recents: [Selection](),
            sections: ToolsLibrary.sections,
            selection: currentSelection,
            isSearching: false,
            collapsedSections: .constant(CollapsedSections()),
            layout: .grid,
            showsSectionHeaders: false,
            onSelect: select,
            cardModel: ToolsLibrary.cardModel(for:),
            contextMenu: { _ in EmptyView() }
        )
        .navigationTitle("Tools")
        #if os(iOS) || os(macOS)
        .crossPromoBanner()
        #endif
    }

    private var currentSelection: Selection? {
        #if os(iOS)
        path.first
        #else
        selection
        #endif
    }

    /// Opens `item`: pushes it on iOS, shows it in the detail column on macOS.
    private func select(_ item: Selection) {
        #if os(iOS)
        path = [item]
        #else
        selection = item
        preferredCompactColumn = .detail
        #endif
    }
```

- [ ] **Step 2: Add a sidebar symbol per tool** — in `DrinkoPro/Views/Tools/ToolsLibrary.swift`, after `cardModel(for:)`:

```swift
    /// The SF Symbol for a tool's iPad sidebar row (`Tab` takes a symbol, not the card's artwork).
    static func sidebarSymbol(for item: ToolsView.Selection) -> String {
        switch item {
        case .abvCalculator: "percent"
        case .superjuice: "drop"
        }
    }
```

  and a test in `DrinkoProTests/ToolsLibraryTests.swift`:

```swift
    @Test func sidebarSymbols() {
        #expect(ToolsLibrary.sidebarSymbol(for: .abvCalculator) == "percent")
        #expect(ToolsLibrary.sidebarSymbol(for: .superjuice("lime")) == "drop")
    }
```

- [ ] **Step 3: Build iOS and macOS; run the full test suite.** Expected `exit 0`.
- [ ] **Step 4: Commit**

```bash
git add DrinkoPro/Views/Tools/ToolsView.swift DrinkoPro/Views/Tools/ToolsLibrary.swift DrinkoProTests/ToolsLibraryTests.swift
git commit -m "Push Tools pages on iOS and add sidebar symbols for tools

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: Cabinet — stack navigation and a category preset

**Files:**
- Modify: `DrinkoPro/Views/Cabinet/CabinetView.swift` (iOS-only file)

**Interfaces:**
- Produces: `CabinetView.init(categoryID: UUID? = nil)`.

- [ ] **Step 1: State, init, body.** Replace from `@State private var showAddCategorySheet` through the end of `body` with:

```swift
    /// When set, the page shows only this category (an iPad sidebar row). `nil` shows all.
    private let categoryID: UUID?

    @State private var showAddCategorySheet: Bool = false
    @State private var selectedProduct: Item?
    @State private var selectedCategory: Category?

    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) var categories: [Category]

    init(categoryID: UUID? = nil) {
        self.categoryID = categoryID
    }

    private var visibleCategories: [Category] {
        categories.filter { categoryID == nil || $0.id == categoryID }
    }

    private var title: String {
        if let categoryID, let category = categories.first(where: { $0.id == categoryID }) {
            return category.name
        }
        return String(localized: "Cabinet")
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleCategories.isEmpty {
                    unavailableView
                } else {
                    categoriesList
                }
            }
            .navigationTitle(title)
            .toolbar {
                if categoryID == nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add Category", systemImage: "plus") {
                            showAddCategorySheet.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView()
                    .presentationDetents([.medium, .large])
            }
            .navigationDestination(item: $selectedProduct) { product in
                EditProductView(product: product, onDelete: { clearSelection(after: product) })
            }
            .navigationDestination(item: $selectedCategory) { category in
                EditCategoryView(category: category, onDelete: { clearSelection(after: category) })
            }
            #if os(iOS)
            .crossPromoBanner()
            #endif
        }
    }
```

- [ ] **Step 2: Rest of the file.**
  - In `categoriesList`, `ForEach(categories)` → `ForEach(visibleCategories)`.
  - Delete `detailView` entirely.
  - In `select(_:)`, `edit(_:)`, both `clearSelection(after:)`: delete every `preferredCompactColumn = …` line, and update doc comments from "detail column … compact widths" to "Pushes …" / "Pops …" wording.

- [ ] **Step 3: Build iOS; build macOS (unaffected, sanity); run the full test suite.** Expected `exit 0`.
- [ ] **Step 4: Commit**

```bash
git add DrinkoPro/Views/Cabinet/CabinetView.swift
git commit -m "Push Cabinet pages and add a single-category preset

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: Sidebar groups in `HomeView`

**Files:**
- Modify: `DrinkoPro/HomeView.swift`

**Interfaces:**
- Consumes: `AppTab` (+ `sidebarCocktailFilters`, `fitted`), `FilterOption.pageTitle/sidebarSymbol`, `LessonsViewModel.librarySectionIDs/sectionTitle(for:)`, `ToolsLibrary.calculatorItems/cardModel(for:)/sidebarSymbol(for:)`, `LearnView(sectionID:)`, `CocktailsView(filter:)`, `CabinetView(categoryID:)`, `ToolsDetailView(selection:)`.

- [ ] **Step 1: Query categories.** Add `import SwiftData` and, after the `@SceneStorage` line:

```swift
    // Cabinet categories, for the iPad sidebar's Cabinet group (same order as CabinetView).
    @Query(sort: [
        SortDescriptor(\Category.name),
        SortDescriptor(\Category.creationDate)
    ]) private var categories: [Category]
```

- [ ] **Step 2: Add the groups** after the `Settings` tab inside `TabView`:

```swift
            TabSection("Cocktails") {
                ForEach(AppTab.sidebarCocktailFilters, id: \.self) { filter in
                    Tab(filter.pageTitle, systemImage: filter.sidebarSymbol, value: AppTab.cocktailFilter(filter)) {
                        CocktailsView(filter: filter)
                    }
                    .tabPlacement(.sidebarOnly)
                }
            }
            TabSection("Learn") {
                ForEach(LessonsViewModel.librarySectionIDs, id: \.self) { id in
                    Tab(
                        LessonsViewModel.sectionTitle(for: id) ?? "",
                        systemImage: id == LessonsViewModel.booksSectionID ? "books.vertical" : "book",
                        value: AppTab.learnSection(id)
                    ) {
                        LearnView(sectionID: id)
                    }
                    .tabPlacement(.sidebarOnly)
                }
            }
            TabSection("Tools") {
                ForEach(ToolsLibrary.calculatorItems) { item in
                    Tab(
                        ToolsLibrary.cardModel(for: item).title,
                        systemImage: ToolsLibrary.sidebarSymbol(for: item),
                        value: AppTab.tool(item)
                    ) {
                        NavigationStack {
                            ToolsDetailView(selection: item)
                        }
                        .crossPromoBanner()
                    }
                    .tabPlacement(.sidebarOnly)
                }
            }
            TabSection("Cabinet") {
                ForEach(categories) { category in
                    Tab(category.name, systemImage: "tray", value: AppTab.cabinetCategory(category.id)) {
                        CabinetView(categoryID: category.id)
                    }
                    .tabPlacement(.sidebarOnly)
                }
            }
```

If `LibraryCardModel.title` isn't a `String` (check `DrinkoPro/Views/Library/LibraryCardModel.swift`), convert it to one. If `Tab` has no initializer taking a `String` title plus `systemImage:` and `value:`, use `Tab(value:content:label:)` with `Label(title, systemImage: symbol)` as the label.

- [ ] **Step 3: Fit to categories.** In `fitSelection()`, replace `categoryIDs: []` with `categoryIDs: Set(categories.map(\.id))`, and add after `.onChange(of: horizontalSizeClass) { … }`:

```swift
        // A selected Cabinet category row disappears when the category is deleted.
        .onChange(of: categories.map(\.id)) {
            fitSelection()
        }
```

- [ ] **Step 4: Build iOS and macOS; run the full test suite; lint.** Expected `exit 0`, no lint errors.
- [ ] **Step 5: Commit**

```bash
git add DrinkoPro/HomeView.swift
git commit -m "Add the iPad sidebar groups for cocktails, Learn, tools and Cabinet

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 9: End-to-end verification

**Files:** none (fix-ups go in a follow-up commit only if something fails).

- [ ] **Step 1: Clean checks.** iOS build, macOS build, full tests, `swiftlint lint --quiet` (no errors). `git status --short` shows nothing unexpected (restore pbxproj churn if any).
- [ ] **Step 2: iPad simulator (iPad A16).** Install and launch:

```bash
xcrun simctl boot "iPad (A16)" 2>/dev/null; open -a Simulator
xcodebuild -project DrinkoPro.xcodeproj -scheme DrinkoPro -destination 'platform=iOS Simulator,name=iPad (A16)' -derivedDataPath /private/tmp/claude-501/-Users-filippocilia-Desktop-Projects-iOS-Drinko/3e931ade-17a0-4bd4-a5fa-1d04be395c81/scratchpad/dd build -quiet
xcrun simctl install booted /private/tmp/claude-501/-Users-filippocilia-Desktop-Projects-iOS-Drinko/3e931ade-17a0-4bd4-a5fa-1d04be395c81/scratchpad/dd/Build/Products/Debug-iphonesimulator/DrinkoPro.app
xcrun simctl launch booted $(defaults read /private/tmp/claude-501/-Users-filippocilia-Desktop-Projects-iOS-Drinko/3e931ade-17a0-4bd4-a5fa-1d04be395c81/scratchpad/dd/Build/Products/Debug-iphonesimulator/DrinkoPro.app/Info.plist CFBundleIdentifier)
xcrun simctl io booted screenshot /private/tmp/claude-501/-Users-filippocilia-Desktop-Projects-iOS-Drinko/3e931ade-17a0-4bd4-a5fa-1d04be395c81/scratchpad/ipad-learn.png
```

  Look at the screenshot: floating top tab bar with five tabs, full-width Learn library. If a tap tool works in this environment (e.g. `mcp__xcode__DeviceInteractionSynthesize`, or AXe), also open the sidebar and screenshot it, and open a cocktail filter row. If tapping isn't possible, say so explicitly in the report — do not claim untested flows work.
- [ ] **Step 3: iPhone simulator.** Same steps on an iPhone simulator; screenshot shows the bottom tab bar and the usual Learn page.
- [ ] **Step 4: Report** what was verified by screenshot, by test, and only by code review.

## Manual checks for the user (cannot be automated here)

- Sidebar: each group row opens the right page; Cabinet group updates when adding/deleting a category; deleting the selected category's page falls back to Cabinet.
- Split View narrowing with a sidebar row selected → bottom tab bar on the main tab.
- `drinko://cocktail/<id>` after visiting the Shots page → opens on the main Cocktails page.
- Shots page with list source "My cocktails only" → "No shots to show".
- iPhone: back navigation, tab restore after relaunch, deep link.
- Note: search text is shared between the main Cocktails page and the filter pages (it lives on the shared `CocktailsViewModel`). Accepted for now.
