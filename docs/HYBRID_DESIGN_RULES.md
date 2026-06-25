# Hybrid design rules (Beauty Master shell + competitor patterns)

**Decision (product owner):** **Hybrid** — keep the CodeCanyon template’s walkthrough photography and burgundy/rose brand shell; adopt competitor **component language** (pills, cards, carousels, line icons, onboarding controls) for Verified Glam feature screens.

Implementation uses [`lib/utils/vg_copy.dart`](../lib/utils/vg_copy.dart) and [`lib/components/vg/`](../lib/components/vg/) — see [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) Sprint 1.

---

## Original content policy

Competitor screenshots in [`reference/competitor-screenshots/`](reference/competitor-screenshots/README.md) are **layout inspiration only**.

| Allowed | Not allowed |
|---------|-------------|
| Pill buttons, card radius, carousel structure, progress bars | Competitor app name, logo, or script wordmark |
| Verified Glam copy from product spec (`vg_copy.dart`) | Competitor headline/body strings (“No Scans Yet”, “Glam Up”, etc.) |
| Material icons and original illustrations | Competitor PNG/JPG assets in `images/` or app bundle |
| Pattern-level paywall/settings sheet layout | Pixel-perfect clone of competitor screens |

When in doubt, implement the **interaction pattern** with **Verified Glam** wording and **BMColors** tokens.

---

## Quick reference

| Layer | Source | Rule |
|-------|--------|------|
| Walkthrough photos | Beauty Master template | **Locked** — `images/model_one.jpg`, `model_two.jpg`, `model_three.jpg` |
| Color tokens | `lib/utils/BMColors.dart` | **Locked** — burgundy `#872B3F`, rose `#C79A9A`, scaffold `#F6E3E3` |
| Auth layout | `BMWidgets` upper/lower containers | **Locked** |
| Font | Open Sans (`AppTheme.dart`) | **Locked** until new brand font approved |
| Home, onboarding, scans UI | Competitor reference | **Adopt patterns**, remap colors to `BMColors` |
| Processing / promo paywall | Competitor (teal/dark/gradient) | **Sub-themes** — do not override global light scaffold |
| Bottom nav count | **4 tabs:** Home, Scan, Explore, Profile — settings via header gear |

---

## What we keep (non-negotiable)

From [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md):

1. **Walkthrough** — Full-bleed model `PageView` in `BMWalkThroughScreen.dart`; text may change, photos may not.
2. **Palette** — `bmSpecialColor`, `bmPrimaryColor`, `bmLightScaffoldBackgroundColor`, not competitor coral `#FF6B8B`.
3. **`upperContainer` / `lowerContainer`** on login, register, and similar auth flows.
4. **Splash timing** — 3 seconds → walkthrough (rebrand copy/logo asset when ready).
5. **4-tab dashboard shell** — Home, Scan, Explore, Guide; settings via header gear only.
6. **Open Sans** — Do not switch to Poppins/Montserrat solely to match competitor.

---

## What we adopt (competitor-informed)

From [DESIGN_SYSTEM_COMPETITOR_REFERENCE.md](DESIGN_SYSTEM_COMPETITOR_REFERENCE.md):

| Pattern | Apply to | Token mapping |
|---------|----------|---------------|
| Pill primary CTA | Onboarding, scan, home cards | Fill `bmSpecialColor`, text white |
| White cards on rose scaffold | Home carousel, aesthetic picker | Card `#FFFFFF`, border `bmPrimaryColor` @ 20% opacity |
| Feature carousel + dots | Home “Choose a scan” | Active dot `bmSpecialColor`, inactive `#F6E3E3` |
| Multi-select rows | Beauty goals, skin, concerns | Selected fill `bmSpecialColor`; outline unselected |
| Top progress bar | 9-step questionnaire | Fill `bmSpecialColor`, track `#F6E3E3` |
| Line icons + viewfinder motif | Home, scans empty, settings | Stroke color `bmSpecialColor` or `bmPrimaryColor` |
| Empty state layout | Scan history tab | Illustration circle `bmLightScaffoldBackgroundColor` |
| Settings bottom sheet | More tab | Secondary pills on `#F6E3E3` |
| Photo-in-card carousel | Aesthetic / look type | Inner radius 12–16px |
| Dark processing UI | Post-upload analysis | Separate theme; optional green accent from alt reference |
| Paywall layouts | RevenueCat | **Primary:** dark comparison (`VGPaywallScreen`); **promo:** `VGPaywallPromoSheet` |
| Photo guideline examples | Scan pipeline | Original AI JPGs in `images/vg/guidelines/` — see `docs/assets/GUIDELINE_IMAGE_PROMPTS.md` |

---

## Color remapping cheat sheet

When reviewing competitor screenshots, mentally substitute:

| You see (competitor) | Build with (Verified Glam) |
|----------------------|----------------------------|
| Coral pink button | `bmSpecialColor` button |
| Light pink circle behind icon | `bmLightScaffoldBackgroundColor` or `#FFF7F7` |
| Pink outline on row | `bmSpecialColor` 1px border |
| White screen background | White **card** on `bmLightScaffoldBackgroundColor` **scaffold** |
| Pink script logo | **Verified Glam** logo (TBD) |
| Green scanner UI | Processing sub-screen only |

---

## Screen-level hybrid map

| Verified Glam area | Template file | Competitor screenshot(s) | Hybrid instruction |
|--------------------|---------------|--------------------------|-------------------|
| Splash | `BMSplashScreen` | — | Template splash; Verified Glam branding |
| Walkthrough | `BMWalkThroughScreen` | — | **No competitor imagery** |
| Auth | `BMLoginScreen`, etc. | — | Keep upper/lower layout |
| Questionnaire | *New* | `09`–`15`, `10` | Competitor controls + BM colors |
| Notifications | `BMEnableNotificationScreen` | `20` | Match layout; BM colors |
| Profile ready | `BMWelcomeScreen` | `19` | Benefit cards pattern |
| Rating | *New* | `21` | Late-funnel screen |
| Paywall | `VGPaywallScreen` | `23`, `24` | Dark comparison primary; promo sheet on dismiss |
| Scan guidelines | `VGPhotoGuidelinesScreen` | `17` | Good/bad photo rows with badge overlays |
| Home | `BMHomeFragment` | `01`–`03` | Header + carousel; burgundy header band optional |
| Scans history | `BMAppointmentFragment` | `05` | Empty state + list |
| Settings sheet | `BMBottomSheet` | `07` | Pill menu rows |
| Scan upload | *New* | `16`, `17`, `08` | Pipeline screens |
| Processing | *New* | `18`, alt refs | Dark sub-theme |
| Language | *New / settings* | `22` | List UI only |

---

## Bottom navigation decision

| Option | Pros | Cons |
|--------|------|------|
| **Keep 5 tabs** (current template) | No shell refactor; maps salon UI to features | Differs from competitor; extra tabs need purpose |
| **Move to 2 tabs** (Home + Scans) | Matches competitor; simpler IA | Requires dashboard redesign approval |

**Documented target:** 2 tabs (Home, Scans) for Verified Glam v1 per product spec. **Implementation:** still 5 tabs until user explicitly approves tab reduction (see `TEMPLATE_TO_VERIFIED_GLAM_MAP.md`).

Interim mapping if staying at 5 tabs:

| Tab | Verified Glam role |
|-----|-------------------|
| 0 Home | Feature carousel |
| 1 | Scans or Explore |
| 2 | Scan history |
| 3 | Tips / defer Chat |
| 4 More | Settings + sheet |

---

## Phase 1 UI checklist (when coding starts)

Use this list so implementers do not re-decide design:

- [ ] Read `DESIGN_SYSTEM_LOCKED.md`, this file, and `DESIGN_SYSTEM_COMPETITOR_REFERENCE.md`
- [ ] Confirm walkthrough `model_*.jpg` unchanged
- [ ] Use `BMColors` for all accent fills — no raw `#FF6B8B`
- [ ] Primary actions: pill radius (height/2), min height 48dp
- [ ] Home: “Ready to Glam Up?” + horizontal feature cards with dots
- [ ] Onboarding: top progress bar + back chevron on each step
- [ ] Multi-select vs single-select patterns match screen type (goals vs gender)
- [ ] Scans tab: empty state with illustration + CTA when no data
- [ ] Settings: bottom sheet with pill rows (not raw `ListTile` only)
- [ ] Processing: dark full-screen, not rose scaffold
- [ ] Paywall: one primary style chosen in product doc
- [ ] No competitor brand name or logo in assets or strings
- [ ] Dark mode: test with `AppStore` toggle after changes

---

## Documentation index

| Doc | Role |
|-----|------|
| [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md) | Template shell — always wins for walkthrough, colors, auth |
| [DESIGN_SYSTEM_COMPETITOR_REFERENCE.md](DESIGN_SYSTEM_COMPETITOR_REFERENCE.md) | Full competitor anatomy |
| [reference/competitor-screenshots/](reference/competitor-screenshots/README.md) | Visual archive |
| [TEMPLATE_TO_VERIFIED_GLAM_MAP.md](TEMPLATE_TO_VERIFIED_GLAM_MAP.md) | File-level screen mapping |

*Last updated: hybrid rules — competitor design memory phase.*
