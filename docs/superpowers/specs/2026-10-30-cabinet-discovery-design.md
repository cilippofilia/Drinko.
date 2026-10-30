# Cabinet Discovery — Design

Date: 2026-10-30 · Status: ready for approval

## Intent

A new tool, in the Tools tab, that answers "what can I make with what I've got?" from the bottles the
user has logged in the Cabinet. It also suggests sensible twists when a recipe is missing only its
base spirit, so a well-stocked cabinet turns into a list of drinks to try, not a list of drinks the
user can't make.

## Goals

1. **Make now**: every cocktail (Drinko's catalog plus the user's own) whose bottles are all
   in the Cabinet.
2. **Twists**: cocktails that would be makeable if exactly one base spirit were swapped for a
   sensible substitute that is in the Cabinet (e.g. Negroni → use tequila instead of gin).
3. Tapping either kind of result opens the existing `CocktailDetailView`, with the swap shown at
   the top when it's a twist.
4. The screen says plainly that pantry staples are assumed and only bottles are checked.

## Non-goals

- Shopping lists or "buy one bottle to unlock N drinks".
- Swapping anything other than base spirits (liqueurs, vermouths, amari, bitters, wine are never
  substituted).
- More than one swap per drink.
- Rewriting the recipe's ingredient list for a twist; the swap note is enough.
- New data in the Cabinet model (no new fields, no migrations).

## Anti-goals

- A drink in "Make now" that the user can't actually make because we matched too loosely
  (e.g. "Martini Rosso" covering "dry vermouth"). Wrong positives are worse than misses.
- Twists that a bartender would wince at (vodka in an Old Fashioned).
- Hiding the assumption about staples.

## What counts as a bottle

**Assumed (never checked), the staples:** juices, syrups (including grenadine and orgeat), sugar/sugar cubes, honey, fresh fruit, herbs and spices, eggs, cream/milk,
coffee/espresso, tea, water, salt, pepper, sauces/brines, purées, and all mixers (soda water, tonic,
ginger beer, cola).

**Checked against the Cabinet:** every spirit, liqueur, vermouth, wine/sparkling/fortified wine,
amaro, and bitters.

Edge cases, my calls: falernum and allspice dram are liqueur-like bottles, so they're checked.
Orange blossom water is a staple. The rule of thumb is "would a home bartender keep it in the
fridge or pantry (staple) or on the bar shelf (bottle)?"

The staple list has to work in all five catalog languages (en, it, es, fr, de), following the
fragment-matching approach `MainSpirit(ingredientName:)` already uses. `MainSpirit` already classifies
`.juice` and `.syrup`, so those count as staples automatically.

## Matching a recipe bottle to the Cabinet

A Cabinet `Item` is described by its `name` (often a brand) **and** its `Category.name`. Both are
used.

1. **Base spirits** (`MainSpirit` vodka, gin, whiskey, rum, tequila, cognac): covered when any
   Cabinet item's name or category name resolves to the same `MainSpirit`. So a "Vodkas" category
   holding "Absolut" covers "vodka" and "citron vodka". Sub-styles aren't distinguished; that's a
   known limitation of `MainSpirit` (white vs aged rum, blanco vs reposado, rye vs bourbon).
2. **Other bottles** (liqueurs, vermouths, bitters, wines): both sides are resolved to a shared
   **bottle style** (e.g. `sweetVermouth`, `dryVermouth`, `coffeeLiqueur`, `maraschino`,
   `aromaticBitters`, `greenChartreuse`), and an ingredient is covered when a Cabinet item (name or
   category) resolves to the same style.
   - **Style table (decided):** ship a curated table of the most common bottles, built into the app
     like `MainSpirit`'s fragments. Each style lists its generic names **in all five languages**
     (en, it, es, fr, de, e.g. "dry vermouth", "vermouth secco", "vermut seco", "vermouth sec",
     "trockener Wermut") **and** common brands (e.g. Noilly Prat and Martini Extra Dry → dry vermouth;
     Carpano Antica, Cocchi di Torino and Martini Rosso → sweet vermouth; Kahlúa → coffee liqueur;
     Luxardo → maraschino; Angostura → aromatic bitters). Target: the bottles the bundled catalog
     actually uses, plus their usual brands (about 50–80 entries).
   - Qualifiers that change the bottle (dry vs sweet vermouth, green vs yellow chartreuse) are
     separate styles, to respect the anti-goal.
   - **Fallback:** a recipe bottle with no style in the table is covered only if a Cabinet item's
     name contains the ingredient's full name, case- and diacritic-insensitive (e.g. item
     "Cherry Heering" covers "cherry heering").
   - It all lives in a pure, unit-tested type.
3. **Alternatives** in a recipe name ("bourbon or rye whiskey", "simple syrup/ginger syrup",
   "rum (your choice)", "blended scotch / vodka") are covered if any alternative is covered.
4. **Only `ingredients` count (decided).** Bottles mentioned only in the recipe's `extra` notes
   (rinses, floats, toppers like "absinthe-rinsed coupe" or "float of yellow chartreuse") are
   ignored.

**Data covered:** everything in `CocktailsViewModel.listOfAllDrinks`, meaning cocktails, shots and
the user's own cocktails. *(My call.)* Shots are stored per language, which the five-language style
table already covers.

## Twists

A cocktail is a twist candidate when every bottle is covered **except exactly one base spirit**, and
the Cabinet holds a base spirit from that one's pairing list. Pairings go both ways:

| Pairing | Example |
|---|---|
| Gin ↔ Vodka | Vodka Martini, Vodka Gimlet |
| Gin ↔ Tequila | Tequila Negroni |
| Whiskey ↔ Cognac | Brandy Old Fashioned, Cognac Sazerac |
| Whiskey ↔ Rum | Rum Old Fashioned |
| Rum ↔ Tequila | Tequila Daiquiri |
| Rum ↔ Cognac | Brandy Daiquiri |

Excluded on purpose: vodka standing in for whiskey/rum/cognac; tequila ↔ whiskey.

If two substitutes are available (missing rum, have both tequila and cognac), the result shows one
twist entry listing both options, not two entries. *(My call.)*

A cocktail that is already in "Make now" never appears in Twists.

No twist when the substitute is already a base spirit in the same recipe (e.g. Vieux Carré
missing rye doesn't suggest cognac, which it already uses). *(My call.)*

**Open for the plan:** Tools navigation today holds only `Selection` values, and `Selection(id:)`
only looks through `calculatorItems`. Opening a cocktail from the new tool needs wiring there, and
the plan handles it.

## The screen

- New card in `ToolsLibrary`, in a new section (e.g. "Discover") above or after Calculators.
  New `ToolsView.Selection` case with a stable persisted `id`.
- One screen with two sections: **Make now** and **Twists**, each a list of cocktails using the
  app's existing cocktail row/card style. A twist row also shows its swap ("Use tequila instead
  of gin").
- A short, always-visible note: "Assumes you have juices, syrups, mixers and fresh ingredients.
  Only bottles in your Cabinet are checked."
- Empty states: empty Cabinet (point to the Cabinet tab), and a Cabinet that matches nothing.
- Tapping opens `CocktailDetailView`. For a twist, a banner at the top of the detail shows the
  swap. The detail view takes this as an optional input, so it's unchanged for every other entry
  point.
- Results update live as the Cabinet changes (SwiftData `@Query` on `Item`).
- iOS and macOS, following `LibraryNavigationContainer` as the other tools do.

## Constraints

- iOS/macOS 26, Swift 6 strict concurrency, SwiftUI + `@Observable` `@MainActor` view model,
  no third-party code.
- Cabinet data is SwiftData + CloudKit; read-only here.
- All user-facing strings localized (en, it, es, fr, de).
- Matching and twist logic in pure types with Swift Testing unit tests against real catalog names
  (`DrinkoProTests/cocktails.json`).

## Left to the builder

- The exact token-matching algorithm for non-spirit bottles, within the rules above.
- Card artwork/symbol for the new tool and its sidebar symbol.
- Sort order within each section (A→Z is a fine default).
- Where the swap banner sits visually in the detail view, as long as it's at the top.
