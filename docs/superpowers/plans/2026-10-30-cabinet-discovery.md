# Cabinet Discovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A new Tools entry that lists the cocktails the user can make from their Cabinet bottles, plus one-spirit-swap twists, each opening the existing cocktail detail.

**Architecture:** A pure, `nonisolated` matching engine (bottle classification → cabinet stock → discovery result) under `DrinkoPro/Views/Tools/Discovery/`, tested with Swift Testing. A SwiftUI page reads `@Query` Cabinet items and `CocktailsViewModel.listOfAllDrinks`, runs the engine, and pushes a new `ToolsView.Selection` case that renders `CocktailDetailView` with an optional swap banner.

**Tech Stack:** Swift 6, SwiftUI, SwiftData (read-only), Swift Testing, String Catalogs.

**Spec:** `docs/superpowers/specs/2026-10-30-cabinet-discovery-design.md`

## Global Constraints

- iOS 26 / macOS 26, Swift 6 strict concurrency; `@Observable` classes are `@MainActor`; no third-party code.
- Cabinet (`Item`, `Category`) is SwiftData + CloudKit and is read-only here; no model changes.
- All user-facing strings go in `DrinkoPro/Localization/Localizable.xcstrings` with en, it, es, fr, de.
- Matching is case- and diacritic-insensitive (`folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)`, as `MainSpirit` does).
- Only a recipe's `ingredients` are checked; `extra` is ignored.
- Base spirits are vodka, gin, whiskey, rum, tequila, cognac. Only base spirits are ever swapped, one per drink.
- Pairings (both directions): gin↔vodka, gin↔tequila, whiskey↔cognac, whiskey↔rum, rum↔tequila, rum↔cognac.
- Fixed copy: "Assumes you have juices, syrups, mixers and fresh ingredients. Only bottles in your Cabinet are checked."
- The project uses synchronized folders: new files under `DrinkoPro/` and `DrinkoProTests/` need no `.pbxproj` edits.
- The working tree has unrelated uncommitted edits (`HomeView.swift`, `CrossPromoSignal*`). Work on branch `feature/cabinet-discovery`, `git add` only the files each task names, never those.
- SwiftLint (`.swiftlint.yml`) must pass before each commit: `swiftlint lint --quiet`.

**Test command** (used throughout, `<Suite>` replaced per task):
`xcodebuild test -project DrinkoPro.xcodeproj -scheme DrinkoPro -destination 'platform=iOS Simulator,name=iPhone Air' -only-testing:DrinkoProTests/<Suite> -quiet`

## Review Focus

1. **The suggested "Gins" category.** `MainSpirit(ingredientName: "Gins")` returns `nil` (it needs the exact word "gin"), so a gin bottle in the app's own suggested category wouldn't count. Expected: it counts. Test in Task 3.
2. **A drink with no checked bottles at all** (only staples) would show in "Make now" even with an empty Cabinet. Expected: it's excluded, since drinks need at least one bottle. *(Plan's call.)* Test in Task 4.
3. **Ambiguous brands.** A bare "Martini" covers neither dry nor sweet vermouth; only "Martini Rosso" or "Martini Extra Dry" do. Test in Task 1.
4. **Gin vs ginger.** Neither "ginger beer" nor "ginger liqueur" counts as gin. Test in Task 2.
5. **An item with no category.** `Item.category` is optional, and the item still counts by its own name. Test in Task 3.

---

### Task 1: Bottle style table

**Files:**
- Create: `DrinkoPro/Views/Tools/Discovery/BottleStyle.swift`
- Test: `DrinkoProTests/BottleStyleTests.swift`

**Interfaces:**
- Produces: `nonisolated enum BottleStyle: String, CaseIterable, Sendable` with `init?(name: String)`.

Styles, one per bottle a bartender wouldn't swap for another: sweetVermouth, dryVermouth, blancVermouth, campari, aperol, benedictine, maraschino, orangeLiqueur (Cointreau, triple sec, curaçao, Grand Marnier), aromaticBitters (Angostura, "aromatic bitters"), orangeBitters, peychauds, absinthe, greenChartreuse, yellowChartreuse, coffeeLiqueur, drambuie, apricotLiqueur, peachLiqueur (incl. peach schnapps, crème de pêche), cremeDeCassis, cremeDeViolette, cremeDeCacao, cremeDeMenthe, cremeDeMure, amaretto (Disaronno), cynar, fernet, amaroNonino, lilletBlanc, lilletRouge, finoSherry, amontilladoSherry, port, sparklingWine (champagne, prosecco), redWine, pimms, cherryHeering, allspiceDram, falernum. Each lists its generic names in en/it/es/fr/de plus its common brands as folded fragments. Check fragments most-specific first (e.g. "extra dry" before "martini"), and give a bare brand that covers several styles no entry.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("BottleStyle") struct BottleStyleTests {
    @Test(arguments: [
        ("sweet red vermouth", BottleStyle.sweetVermouth), ("Carpano Antica Formula", .sweetVermouth),
        ("Vermouth Rosso", .sweetVermouth), ("dry vermouth", .dryVermouth), ("Noilly Prat", .dryVermouth),
        ("Vermouth secco", .dryVermouth), ("Vermut seco", .dryVermouth), ("trockener Wermut", .dryVermouth),
        ("Martini Extra Dry", .dryVermouth), ("Martini Rosso", .sweetVermouth),
        ("green chartreuse", .greenChartreuse), ("Chartreuse verde", .greenChartreuse),
        ("yellow chartreuse", .yellowChartreuse), ("Kahlúa", .coffeeLiqueur), ("Luxardo Maraschino", .maraschino),
        ("Cointreau", .orangeLiqueur), ("couintreau", .orangeLiqueur), ("Angostura", .aromaticBitters),
        ("peach schnapps", .peachLiqueur), ("Disaronno", .amaretto), ("prosecco", .sparklingWine)
    ])
    func resolves(_ name: String, _ style: BottleStyle) { #expect(BottleStyle(name: name) == style) }

    @Test(arguments: ["Martini", "Absolut", "lime juice", "London dry gin"])
    func doesNotResolve(_ name: String) { #expect(BottleStyle(name: name) == nil) }
}
```

- [ ] **Step 2: Run them and confirm they fail.** Run the test command with `<Suite>` = `BottleStyleTests`. Expected: FAIL, because `BottleStyle` is not defined.
- [ ] **Step 3: Implement `BottleStyle`**, with a `fragments: [String]` per case and `init?(name:)` returning the first case whose fragment the folded name contains. The order of `allCases` sets precedence.
- [ ] **Step 4: Run the tests and confirm they pass.** Expected: PASS.
- [ ] **Step 5: Commit** both files: `git commit -m "Add bottle style table for cabinet discovery"`

### Task 2: Classifying a recipe ingredient

**Files:**
- Modify: `DrinkoPro/Models/Cocktails/MainSpirit.swift`. Add `var isBaseSpirit: Bool` (true for rank 0).
- Create: `DrinkoPro/Views/Tools/Discovery/RecipeBottle.swift`
- Test: `DrinkoProTests/RecipeBottleTests.swift`

**Interfaces:**
- Consumes: `BottleStyle(name:)`, `MainSpirit(ingredientName:)`.
- Produces:
  - `nonisolated enum RecipeBottle: Hashable, Sendable { case staple, spirit(MainSpirit), style(BottleStyle), other(String) }`
  - `init(name: String)`. Classification order: style → staple → base spirit → other(folded name). Style comes first, and staple fragments match whole words or phrases, so "chocolate bitters" doesn't hit "cola" and "Irish cream liqueur" doesn't hit "cream".
  - `static func alternatives(in name: String) -> [String]`. Splits on " or ", "/", " o ", " ou ", " oder ", and drops parenthesised text.
  - `static func isStaple(_ name: String) -> Bool`. True for `MainSpirit` `.juice`/`.syrup`, plus a five-language fragment list for sugar, honey, fruit, herbs, spices, egg, cream/milk, coffee/espresso, tea, water, salt, pepper, sauces, brine, purée, blossom/flower water, soda, tonic, ginger beer, cola.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("RecipeBottle") struct RecipeBottleTests {
    @Test(arguments: ["lime juice", "simple syrup", "egg white", "mint leaves", "ginger beer", "soda water",
                      "orange blossom water", "heavy cream", "espresso", "sugar cube", "hot sauce", "orgeat (almond syrup)"])
    func staples(_ name: String) { #expect(RecipeBottle(name: name) == .staple) }

    @Test func bottles() {
        #expect(RecipeBottle(name: "london dry gin") == .spirit(.gin))
        #expect(RecipeBottle(name: "falernum") == .style(.falernum))
        #expect(RecipeBottle(name: "maraschino liqueur") == .style(.maraschino))
        #expect(RecipeBottle(name: "onion brine") == .staple)
        #expect(RecipeBottle(name: "ginger liqueur") != .spirit(.gin))
        #expect(RecipeBottle(name: "chocolate bitters") != .staple)
        #expect(RecipeBottle(name: "irish cream liqueur") != .staple)
        #expect(RecipeBottle(name: "Some Rare Amaro") == .other("some rare amaro"))
    }

    @Test func alternatives() {
        #expect(RecipeBottle.alternatives(in: "bourbon or rye whiskey") == ["bourbon", "rye whiskey"])
        #expect(RecipeBottle.alternatives(in: "blended scotch / vodka") == ["blended scotch", "vodka"])
        #expect(RecipeBottle.alternatives(in: "rum (your choice)") == ["rum"])
    }
}
```

- [ ] **Step 2: Run them and confirm they fail.** `<Suite>` = `RecipeBottleTests`. Expected: FAIL, because `RecipeBottle` is not defined.
- [ ] **Step 3: Implement** `MainSpirit.isBaseSpirit` and `RecipeBottle`. A `.spirit` result is only produced when `isBaseSpirit`; a liqueur `MainSpirit` without a style falls to `.other`.
- [ ] **Step 4: Add a catalog coverage test** to `RecipeBottleTests`. Decode `[Cocktail]` from the app bundle's `cocktails.json` the way `WidgetStickerTests` does. Then, for every alternative of every ingredient, `#expect` the result isn't `.other`, with a `Comment` naming the ingredient. Add missing fragments until it passes: fresh produce and kitchen items (cucumber, marmalade, strawberry) go in the staple list, and bar bottles go in Task 1's table. This test is what keeps both lists complete.
- [ ] **Step 5: Run the tests and confirm they pass.** Expected: PASS.
- [ ] **Step 6: Commit** the four files: `git commit -m "Classify recipe ingredients into staples and bottles"`

### Task 3: Cabinet stock

**Files:**
- Create: `DrinkoPro/Views/Tools/Discovery/CabinetStock.swift`
- Test: `DrinkoProTests/CabinetStockTests.swift`

**Interfaces:**
- Consumes: `RecipeBottle`, `BottleStyle`, `MainSpirit`.
- Produces: `nonisolated struct CabinetStock: Sendable`, with:
  - `init(bottles: [(name: String, category: String?)])`
  - `let spirits: Set<MainSpirit>`
  - `func covers(_ ingredientName: String) -> Bool`. True if any alternative is a staple, or a spirit/style in stock, or an `.other` name contained in some stocked folded name.

Each bottle is read as `"\(name) \(category ?? "")"`. On the cabinet side only, a word ending in "s" is also tried without the "s", so "Gins" resolves to gin.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("CabinetStock") struct CabinetStockTests {
    @Test func spiritsResolveFromCategoryOrName() {
        let stock = CabinetStock(bottles: [("Absolut", "Vodkas"), ("Bombay Sapphire", "Gins"), ("Lagavulin", nil)])
        #expect(stock.spirits == [.vodka, .gin])  // "Lagavulin" alone names no spirit
        #expect(stock.covers("citron vodka"))
        #expect(stock.covers("london dry gin"))
    }
    @Test func stylesNeedTheRightQualifier() {
        let stock = CabinetStock(bottles: [("Carpano Antica", "Vermouth")])
        #expect(stock.covers("sweet red vermouth"))
        #expect(!stock.covers("dry vermouth"))
    }
    @Test func uncategorisedItemCountsByName() {
        #expect(CabinetStock(bottles: [("Campari", nil)]).covers("campari"))
    }
    @Test func fallbackNeedsTheFullName() {
        let stock = CabinetStock(bottles: [("Some Rare Amaro 1888", "Amari")])
        #expect(stock.covers("some rare amaro"))
        #expect(!stock.covers("rare whisky liqueur"))
    }
    @Test func alternativesAndStaples() {
        let stock = CabinetStock(bottles: [("Rittenhouse Rye", "Whiskeys")])
        #expect(stock.covers("bourbon or rye whiskey"))
        #expect(CabinetStock(bottles: []).covers("lime juice"))
    }
}
```

- [ ] **Step 2: Run them and confirm they fail.** `<Suite>` = `CabinetStockTests`. Expected: FAIL, because `CabinetStock` is not defined.
- [ ] **Step 3: Implement `CabinetStock`.** Store `spirits`, `styles: Set<BottleStyle>` and `names: [String]` (folded).
- [ ] **Step 4: Run the tests and confirm they pass.** Expected: PASS.
- [ ] **Step 5: Commit** both files: `git commit -m "Build cabinet stock for discovery matching"`

### Task 4: Discovery engine and twists

**Files:**
- Create: `DrinkoPro/Views/Tools/Discovery/SpiritSwap.swift`, `DiscoveryMatch.swift`, `CabinetDiscovery.swift`
- Test: `DrinkoProTests/CabinetDiscoveryTests.swift`

**Interfaces:**
- Consumes: `CabinetStock`, `RecipeBottle`, `MainSpirit.isBaseSpirit`.
- Produces:
  - `nonisolated struct SpiritSwap: Hashable, Sendable { let missing: MainSpirit; let substitutes: [MainSpirit] }`, plus `static func substitutes(for: MainSpirit) -> [MainSpirit]` (the pairings from Global Constraints, in table order) and `var message: String`, for example `String(localized: "Use \(substitutes.map(\.displayName).formatted(.list(type: .or))) instead of \(missing.displayName)")`.
  - `nonisolated struct DiscoveryMatch: Hashable, Identifiable, Sendable { let cocktail: Cocktail; let swap: SpiritSwap? }`, with `id` = `cocktail.id`.
  - `nonisolated enum CabinetDiscovery { static func discover(in cocktails: [Cocktail], stock: CabinetStock) -> (makeNow: [DiscoveryMatch], twists: [DiscoveryMatch]) }`. Both lists are sorted by `name` with `localizedStandardCompare`.

These are the rules, since the signatures don't fix them:
- A drink with no non-staple ingredient is in neither list.
- Make now: every ingredient is covered.
- Twist: exactly one ingredient is uncovered, and it is a base spirit S. Substitutes are `substitutes(for: S)` that are in `stock.spirits` and that aren't a base spirit of another ingredient of the drink. The drink is a twist only if that list isn't empty.

- [ ] **Step 1: Write the failing tests**, using inline `Cocktail(id:name:method:glass:garnish:ice:extra:ingredients:)` fixtures:

```swift
@Suite("CabinetDiscovery") struct CabinetDiscoveryTests {
    // negroni = gin + campari + sweet red vermouth; daiquiri = white rum + lime + simple syrup;
    // vieuxCarre = rye whiskey + cognac + sweet red vermouth + dom benedictine; virgin = lime juice + soda water
    @Test func makeNow() {
        let stock = CabinetStock(bottles: [("Tanqueray", "Gins"), ("Campari", nil), ("Martini Rosso", nil)])
        let result = CabinetDiscovery.discover(in: [negroni, daiquiri, virgin], stock: stock)
        #expect(result.makeNow.map(\.cocktail.id) == ["negroni"])
        #expect(result.makeNow.first?.swap == nil)
    }
    @Test func twistSwapsOnlySensiblePairs() {
        let stock = CabinetStock(bottles: [("Olmeca", "Tequilas & Mezcals"), ("Absolut", "Vodkas"), ("Campari", nil), ("Carpano Antica", nil)])
        let twist = CabinetDiscovery.discover(in: [negroni], stock: stock).twists.first
        #expect(twist?.swap == SpiritSwap(missing: .gin, substitutes: [.vodka, .tequila]))
    }
    @Test func noTwistWhenSubstituteIsAlreadyInTheDrink() {
        let stock = CabinetStock(bottles: [("Hennessy", "Cognacs"), ("Carpano Antica", nil), ("Bénédictine", nil)])
        #expect(CabinetDiscovery.discover(in: [vieuxCarre], stock: stock).twists.isEmpty)
    }
    @Test func noTwistForUnpairedSpirit() {
        let stock = CabinetStock(bottles: [("Absolut", "Vodkas")])
        #expect(CabinetDiscovery.discover(in: [daiquiri], stock: stock).twists.isEmpty)
    }
    @Test func emptyCabinetFindsNothing() {
        let result = CabinetDiscovery.discover(in: [negroni, daiquiri, virgin], stock: CabinetStock(bottles: []))
        #expect(result.makeNow.isEmpty && result.twists.isEmpty)
    }
    @Test func swapMessage() {
        #expect(SpiritSwap(missing: .gin, substitutes: [.tequila]).message == "Use Tequila instead of Gin")
    }
}
```

- [ ] **Step 2: Run them and confirm they fail.** `<Suite>` = `CabinetDiscoveryTests`. Expected: FAIL, because the types are not defined.
- [ ] **Step 3: Implement** `SpiritSwap`, `DiscoveryMatch` and `CabinetDiscovery`. Add the "Use … instead of …" key to `Localizable.xcstrings` in all five languages.
- [ ] **Step 4: Run the tests and confirm they pass.** Expected: PASS.
- [ ] **Step 5: Commit** the four files plus `Localizable.xcstrings`: `git commit -m "Add cabinet discovery engine with spirit twists"`

### Task 5: Tools entry, discovery page, and swap banner

**Files:**
- Modify: `DrinkoPro/Views/Tools/ToolsView+Selection.swift`. Add `case cabinetDiscovery` (id `"discovery"`) and `case discoveredCocktail(DiscoveryMatch)` (id `"discovered:\(match.id)"`). Make `init(id:)` also look through `ToolsLibrary.discoverItems`.
- Modify: `DrinkoPro/Views/Tools/ToolsLibrary.swift`.
  - Add `static let discoverSectionID = "discover"` and `nonisolated static var discoverItems: [ToolsView.Selection] { [.cabinetDiscovery] }`.
  - Add a "Discover" section before Calculators.
  - Add the `.cabinetDiscovery` card: title "What Can I Make?", subtitle "Cocktails you can mix with the bottles in your Cabinet.", image `.symbol("cabinet")`. Sidebar symbol `"cabinet"`.
  - `.discoveredCocktail` never appears in sections. Its `cardModel` and `sidebarSymbol` branches return the cocktail's name and `"wineglass"`, with a one-line comment saying they're unreachable.
- Modify: `DrinkoPro/Views/Tools/ToolsDetailView.swift`. `.cabinetDiscovery` → `CabinetDiscoveryView()`; `.discoveredCocktail(let match)` → `CocktailDetailView(cocktail: match.cocktail, swap: match.swap)`.
- Create: `DrinkoPro/Views/Tools/Discovery/CabinetDiscoveryView.swift`
- Create: `DrinkoPro/Views/Tools/Discovery/DiscoveryMatchRow.swift`
- Create: `DrinkoPro/Views/Cocktails/Cocktail/CocktailSwapBanner.swift`
- Modify: `DrinkoPro/Views/Cocktails/CocktailDetailView.swift`. Add `var swap: SpiritSwap? = nil` and show `CocktailSwapBanner(swap:)` as the first child of the `VStack`, above `CocktailImageHeader`, when it's non-nil.
- Modify: `DrinkoPro/HomeView.swift:70-80`, the iPad sidebar "Tools" section.
  - Iterate `ToolsLibrary.discoverItems + ToolsLibrary.calculatorItems`.
  - Add `.navigationDestination(for: ToolsView.Selection.self) { ToolsDetailView(selection: $0) }` inside its `NavigationStack`, so rows pushed from the discovery page route there too.
  - **This file has the user's uncommitted edits.** Stage only this hunk with `git add -p`, or ask the user first.
- Modify: `DrinkoPro/Localization/Localizable.xcstrings`

**Interfaces:**
- Consumes: `CabinetDiscovery.discover(in:stock:)`, `CabinetStock(bottles:)`, `DiscoveryMatch`, `SpiritSwap.message`, `CocktailsViewModel.listOfAllDrinks`, `CocktailsViewModel.cardModel(for:)`.
- Produces: `struct CabinetDiscoveryView: View` (no parameters), `struct DiscoveryMatchRow: View { let match: DiscoveryMatch }`, `struct CocktailSwapBanner: View { let swap: SpiritSwap }`.

How `CabinetDiscoveryView` works:
- `@Query private var items: [Item]` and `@Environment(CocktailsViewModel.self)`. It builds `CabinetStock(bottles: items.map { ($0.name, $0.category?.name) })` and calls `discover`.
- It's a `List` with the fixed staples copy as its header text, a "Make Now" section and a "Twists" section, and hides a section when it's empty.
- Each row is `NavigationLink(value: ToolsView.Selection.discoveredCocktail(match)) { DiscoveryMatchRow(match:) }`. The Tools stack's typed path and the macOS detail's `navigationDestination(for: ToolsView.Selection.self)` already route it. The row shows the cocktail's card image and name, and `swap.message` as a secondary line when present.
- Empty states use `ContentUnavailableView`:
  - Empty Cabinet: "Your Cabinet Is Empty", "Add the bottles you own to see what you can make.", symbol `cabinet`.
  - No matches: "No Matches Yet", "Add a few more bottles to your Cabinet to unlock cocktails.", symbol `wineglass`.
- `.navigationTitle("What Can I Make?")`.
- `CocktailSwapBanner` shows `swap.message` with `Label(…, systemImage: "arrow.triangle.swap")`, styled like `DetailSectionCard`.
- Every new string goes into `Localizable.xcstrings` with it, es, fr, de translations.

- [ ] **Step 1: Write a failing test** in `DrinkoProTests/CabinetDiscoveryTests.swift`:

```swift
@Test func discoverySelectionRoundTripsItsID() {
    #expect(ToolsView.Selection(id: "discovery") == .cabinetDiscovery)
    #expect(ToolsLibrary.sections.first?.id == ToolsLibrary.discoverSectionID)
}
```

- [ ] **Step 2: Run it and confirm it fails.** `<Suite>` = `CabinetDiscoveryTests`. Expected: FAIL, because `.cabinetDiscovery` is not defined.
- [ ] **Step 3: Implement** all the file changes above.
- [ ] **Step 4: Run the full test suite and build macOS.**
  - Run: `xcodebuild test -project DrinkoPro.xcodeproj -scheme DrinkoPro -destination 'platform=iOS Simulator,name=iPhone Air' -quiet`. Expected: all tests pass.
  - Run: `xcodebuild build -project DrinkoPro.xcodeproj -scheme DrinkoDesktop -destination 'platform=macOS' -quiet`. Expected: `BUILD SUCCEEDED`, which confirms exhaustive switches on macOS.
- [ ] **Step 5: Check it by hand in the simulator.** Add "Tanqueray" in "Gins", "Campari" and "Carpano Antica". Expected:
  - Negroni appears under Make Now.
  - With the gin deleted and a tequila added, Negroni moves to Twists with "Use Tequila instead of Gin".
  - Tapping it opens the detail with the banner on top.
  - The Cocktails tab detail shows no banner.
  - On iPad, the sidebar's "What Can I Make?" entry pushes the detail the same way.
- [ ] **Step 6: Lint and commit.** Run `swiftlint lint --quiet` and expect no errors. Commit the files above: `git commit -m "Add What Can I Make? tool to Tools"`.
