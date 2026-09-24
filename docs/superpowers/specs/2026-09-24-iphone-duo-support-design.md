# iPhone Duo Support — Design

## Context

Apple has announced iPhone Duo, a foldable iPhone with a compact outer
display and a large inner display, launching alongside Xcode 27.1 beta
(iOS 27.1 SDK). Confirmed locally: `xcodebuild -showsdks` lists iOS
27.1 SDK under Xcode beta 27.1, and `xcrun simctl list devicetypes`
lists `iPhone Duo (com.apple.CoreSimulator.SimDeviceType.iPhone-Duo)`.
Apple's developer documentation (`developer.apple.com/iphone-duo/` and
its linked technology overview) describes the device model: content
reflows across closed (outer), open (inner), and partially-folded
states; the system exposes `reservedRegions` (fold + camera occlusion
areas), new `UITraitCollection` properties
(`horizontalSizeClass`/`verticalSizeClass`/`verticalBarEdge`), and new
containers (`ArrangementView` / `UIArrangementViewController` with
split/overlay styles). Guidance explicitly warns against using
`UIDevice.userInterfaceIdiom` or `UIInterfaceOrientation` for layout
decisions, and recommends preferring standard system containers
(`NavigationStack`, `NavigationSplitView`, `TabView`, stacks) which
adapt automatically, over custom fixed-size layout.

## Goal

Make Drinko's iOS app (`DrinkoPro`) adapt correctly to iPhone Duo's
outer/inner displays and fold transitions, using standard SwiftUI
adaptivity rather than bespoke fold-aware layout code, and fix the one
existing layout anti-pattern that would break outright on this device.

## Scope

In scope: `DrinkoPro` target — root navigation (`HomeView`), the
`screenWidth` global sizing anti-pattern and its call sites, a pass
over full-bleed image headers and sheet presentations.

Out of scope:
- **Camera work** — Drinko has no camera feature.
- **Multi-scene / multi-window support** — Drinko is a single-window
  utility app; Apple's multi-scene guidance for Duo doesn't apply.
- **`DrinkoMac`** — unaffected; remains its own independent target
  and navigation shell.

## Design

### 1. Root navigation shell

`DrinkoPro/HomeView.swift` currently uses a plain `TabView`/`Tab` at
the root (phone-style tab bar). Add `.tabViewStyle(.sidebarAdaptable)`
to that `TabView`. On today's iPhones and on Duo's compact outer
display this renders exactly as it does today (a tab bar); on Duo's
large inner display the system automatically promotes it to a
sidebar. This reuses the existing `Tab` definitions and
`AppNavigationModel`-backed selection binding as-is — no new
navigation model, no duplicated view hierarchy, and no coupling to
`DrinkoMac`'s separate `NavigationSplitView` shell (`MacHomeView`),
which stays untouched.

### 2. Fix the `screenWidth` global

`DrinkoPro/Helpers/GlobalConstant.swift` defines:

```swift
let screenWidth: CGFloat = UIScreen.main.bounds.width
```

computed once at process launch from the whole physical screen. This
is precisely the anti-pattern Apple's Duo guidance calls out — layout
sizing must come from the view's actual container, not a global
screen snapshot — and it will be wrong across Duo's fold states (and
is already unreliable in any multi-window iPad scenario today).

Call sites to migrate: `BookDetailView`, `LessonDetailView`,
`CabinetView`, `ReadMeView`, `CocktailRowView` (`frameSize`), and any
other consumer of `screenWidth` found under `DrinkoPro/Views`. Replace
with `.containerRelativeFrame(...)` where a simple relative fraction
suffices, and `GeometryReader` only where relative-frame can't express
the calculation, per this repo's existing convention (CLAUDE.md:
"Avoid GeometryReader if a newer alternative would work as well").

The `screenWidth` global constant itself is removed once all call
sites are migrated.

### 3. Bars, sheets, and full-bleed content audit

- Toolbars already use `ToolbarItem` placements throughout — vertical
  bar presentation on the outer display / leading-trailing edges on
  the inner display is automatic for these per Apple's bar
  presentation rules table. No code changes anticipated here beyond
  verification.
- Spot-check `CocktailImageHeader` and `SplashScreenView` for
  full-bleed image content that could sit under a vertical bar or
  inside the fold's reserved region; apply `.backgroundExtensionEffect()`
  where the visual result needs it.
- Sheets (`WidgetTutorialView`, `AddCategoryView`, `EditProductView`,
  `UserCocktailForm`) get a manual pass to confirm default
  presentation placement reads correctly across Duo's split states.
  Only add explicit `.presentationPlacement(...)` overrides where the
  default placement looks wrong once tested — no speculative changes.

### 4. Build & test setup

- Requires Xcode 27.1 beta / iOS 27.1 SDK, both confirmed installed.
- No `IPHONEOS_DEPLOYMENT_TARGET` change needed (currently 18.0) — all
  three changes above are backward-compatible; Duo-specific behavior
  (sidebar promotion, reserved-region-aware layout) is purely a system
  runtime adaptation on Duo hardware/simulator, not an API gated
  behind a version bump.
- Manual test pass on the `iPhone Duo` simulator: closed (outer),
  fully open (inner), and partially folded, across all four tabs
  (Learn, Cocktails, Cabinet, Settings) plus the sheets listed above.

## Testing

- No new unit-testable logic is introduced (this is layout-only); the
  `screenWidth` migration should not change any view model or business
  logic under test in `DrinkoProTests`.
- Verification is manual, via the `iPhone Duo` simulator across the
  three fold states listed in section 4, checking Apple's testing
  checklist: layout resizes gracefully, sheets/popovers position
  correctly, no content sits in the fold's reserved region, bars
  present correctly.
