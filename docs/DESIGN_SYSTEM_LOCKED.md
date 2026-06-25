# Verified Glam — Locked Design System

This document defines the **non-negotiable UI/UX** for the Verified Glam app. It is extracted from the CodeCanyon **Beauty Master** Flutter template currently in this repository. Future work may change **copy, data, and features** but must preserve these visual and structural patterns unless the product owner explicitly approves a redesign.

**Source files:** `lib/utils/BMColors.dart`, `lib/utils/AppTheme.dart`, `lib/utils/BMWidgets.dart`, walkthrough and home screens.

---

## Brand shell vs product content

| Layer | Status |
|-------|--------|
| Colors, typography, layout chrome, walkthrough photography | **Locked** |
| App name, slogans, feature names, API data | **Verified Glam content** (see `VERIFIED_GLAM_PRODUCT.md`) |

---

## Color palette

| Token | Hex | RGB (approx.) | Usage |
|-------|-----|---------------|--------|
| `bmPrimaryColor` | `#C79A9A` | 199, 154, 154 | Icons, accents, unselected nav tint, links |
| `bmSpecialColor` | `#872B3F` | 135, 43, 63 | Header bands (`upperContainer`), primary buttons, home status bar |
| `bmSpecialColorDark` | `#520D1C` | 82, 13, 28 | Section titles (light mode), emphasis text |
| `bmLightScaffoldBackgroundColor` | `#F6E3E3` | 246, 227, 227 | Main scaffold (light) |
| `bmSecondBackgroundColorLight` | `#FFF7F7` | 255, 247, 247 | Alternate tab backgrounds (tabs 1–3) |
| `bmSecondBackgroundColorDark` | `#454444` | 69, 68, 68 | Alternate tab backgrounds (dark) |
| `bmGreyColor` | `#8D8C8C` | 141, 140, 140 | Secondary text, register links |
| `bmBlueColor` | `#1157FA` | 17, 87, 250 | `CustomTheme` secondary (scoped widgets) |

### Text (light theme)

| Token | Hex | Usage |
|-------|-----|--------|
| `appTextColorPrimary` | `#212121` | Body text |
| `appTextColorSecondary` | `#5A5C5E` | Subtitles |
| `bmTextColorDarkMode` | `Colors.grey` | Muted text in dark mode |

### Dark theme surfaces

| Token | Hex | Usage |
|-------|-----|--------|
| `appBackgroundColorDark` | `#262626` | Scaffold dark |
| `cardBackgroundBlackDark` | `#1F1F1F` | Cards dark |
| `color_primary_black` | `#131D25` | Primary dark accent |
| `appSecondaryBackgroundColor` | `#343434` | Secondary surfaces |

### Social (login row)

| Network | Hex |
|---------|-----|
| Facebook | `#3B5997` |
| Twitter | `#1DA0F1` |

---

## Typography

- **Font family:** Google Fonts **Open Sans** (`AppThemeData` in `lib/utils/AppTheme.dart`)
- **Header (auth / upper panel):** `boldTextStyle`, size **30**, color **white** (`headerText`)
- **Section titles:** `boldTextStyle`, size **20**, color `bmSpecialColorDark` (light) or white (dark)
- **Walkthrough title:** `boldTextStyle`, size **24**, color **white**
- **Walkthrough subtitle:** `primaryTextStyle`, color **white**, centered
- **Buttons:** `boldTextStyle`, size **14–20**, white on `bmPrimaryColor` or grey secondary

---

## Layout patterns

### `upperContainer` + `lowerContainer`

Signature two-part screen layout used on login, register, and similar flows:

1. **Upper:** Rounded bottom-left corner (**40px**), fill `bmSpecialColor`, padding **20**, often contains `headerText`.
2. **Lower:** Outer wrapper `bmSpecialColor`, inner body with **top-right radius 40**, fill `bmLightScaffoldBackgroundColor` (light) or `appStore.scaffoldBackground` (dark).

Do not replace with flat single-column layouts without approval.

### Walkthrough (critical — user-approved)

**File:** `lib/screens/BMWalkThroughScreen.dart`

| Rule | Detail |
|------|--------|
| Structure | Full viewport height `PageView` with **full-bleed** `Image.asset` (`BoxFit.cover`) |
| Assets | **Keep** `images/model_one.jpg`, `images/model_two.jpg`, `images/model_three.jpg` |
| Overlay | Bottom stack: title, subtitle, page dots, **Get Started** pill CTA |
| Skip | Top-right → onboarding (if incomplete) or Home dashboard; same smart routing as Get Started |
| Auth on walkthrough | **Removed** — Login/Join not shown here; account auth reserved for premium subscribers later |
| Status bar | Transparent on walkthrough |

**Allowed later:** Change title/subtitle strings only. **Not allowed:** Replace model photos with flat illustrations unless new assets are provided and approved.

### Splash

**File:** `lib/screens/BMSplashScreen.dart`

- Logo: `images/verified_glam_logo.png`, height **200**
- Brand line below logo
- Background: `bmLightScaffoldBackgroundColor` (light) or `appStore.scaffoldBackground` (dark)
- Auto-advance **3 seconds** → walkthrough

### Home

**File:** `lib/fragments/BMHomeFragment.dart`

- Status bar: `bmSpecialColor` on init
- `HomeFragmentHeadComponent` in upper area (burgundy header pattern)
- `lowerContainer` for scrollable sections
- Horizontal lists and “See All” row pattern with arrow icon
- Card list via `BMCommonCardComponent` (reuse for feature cards later)

### Bottom navigation

**File:** `lib/screens/BMDashboardScreen.dart`

- **5 tabs** (indices 0–4): Home, Search/Upsell slot, Appointments, Chat, More
- Bar: rounded top corners (**32**), icon-only (labels hidden)
- Tint: `bmPrimaryColor` for icons
- Tab background alternates by index (see `getDashboardColor()`)

Future Verified Glam may **repurpose tab content** but should keep **5-slot shell** until a deliberate nav redesign is approved.

### Cards

**File:** `lib/components/BMCommonCardComponent.dart`

- Image top, title, subtitle, rating/distance row pattern
- Reuse dimensions and tap → detail navigation for **scan feature cards**

### Buttons

- Primary: `AppButton` / `VGPillButton`, `bmSpecialColor`, pill radius **32**
- Walkthrough CTA: single full-width **Get Started** (`VGCopy.walkthroughGetStarted`)
- `defaultRadius` from `nb_utils`: **10** (global in `main.dart`)

---

## Theme modes

- **Light / dark** toggled via `AppStore` (`lib/store/AppStore.dart`)
- Toggle UI in `BMMoreFragment` (switch + sun/moon icon)
- Preference key: `isDarkModeOnPref`
- Material 3 enabled in `AppThemeData` with palette above

---

## Icons and imagery

- Tab bar: PNG assets under `images/` (`home.png`, `calendar.png`, etc.)
- Prefer **Material Icons** for in-screen actions unless template uses asset icons
- Verified Glam spec prefers **SVG icon sets** (Heroicons/Lucide) for new UI — use only where they match existing size and color tokens

---

## Motion and density

- Page transitions: `OpenUpwardsPageTransitionsBuilder` (Android), `CupertinoPageTransitionsBuilder` (iOS)
- `visualDensity: adaptivePlatformDensity`
- Hover on cards: `appStore.toggleHover` pattern in components (web/desktop)

---

## Anti-goals (do not do without explicit approval)

1. Replace walkthrough model photography with wireframe/Lottie-only slides from generic beauty-app specs.
2. Apply **ui-ux-pro-max** or other generic palettes (e.g. soft pink `#EC4899` / lavender) over burgundy + dusty rose.
3. Change primary brand color from `#872B3F` / `#C79A9A` family.
4. Remove `upperContainer` / `lowerContainer` auth layout pattern.
5. Collapse 5-tab navigation to 2 tabs without product sign-off.
6. Switch framework or rewrite navigation (stay on Flutter + existing component set).

---

## Pre-delivery UI checklist (template-aligned)

When adding or changing screens, verify:

- [ ] Uses locked colors from `BMColors` (no hardcoded random pinks)
- [ ] Light mode text contrast readable on `#F6E3E3` / white panels
- [ ] `cursor-pointer` / tap targets on all interactive elements (Flutter: `InkWell` / `GestureDetector`)
- [ ] Dark mode tested via `AppStore` toggle
- [ ] Back navigation uses `finish(context)` / template `appBar` pattern
- [ ] Walkthrough assets unchanged unless new images supplied
- [ ] Status bar color set in `initState` / `dispose` per screen convention

---

## Hybrid layer (competitor-informed)

Product owner approved a **hybrid** approach: this file remains the **authority for shell** (colors, walkthrough, auth layout, tab count until changed). Competitor UI patterns (pill buttons, feature carousels, onboarding rows, settings sheet, paywall layouts) are documented separately and **must use `BMColors` tokens**, not competitor coral pink hex values.

| Document | Purpose |
|----------|---------|
| [HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md) | What to keep vs adopt; Phase 1 checklist |
| [DESIGN_SYSTEM_COMPETITOR_REFERENCE.md](DESIGN_SYSTEM_COMPETITOR_REFERENCE.md) | Full competitor anatomy (reference only) |
| [reference/competitor-screenshots/README.md](reference/competitor-screenshots/README.md) | Archived screenshot index |

**Default for new screens (not walkthrough):** Follow hybrid rules + competitor component patterns, remapped to burgundy/rose palette above.

---

## Related docs

- `docs/VERIFIED_GLAM_PRODUCT.md` — product requirements
- `docs/TEMPLATE_TO_VERIFIED_GLAM_MAP.md` — screen mapping
- `docs/HYBRID_DESIGN_RULES.md` — competitor pattern adoption
- `docs/DESIGN_SYSTEM_COMPETITOR_REFERENCE.md` — competitor visual reference
- `docs/design-system/MASTER.md` — short pointer to this file

*Last updated: documentation phase — Beauty Master template baseline + hybrid layer.*
