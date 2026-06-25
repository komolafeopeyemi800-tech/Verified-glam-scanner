# Competitor design system reference (Glam Up / beauty-scanner category)

**Purpose:** Persistent memory of UI patterns from high-install competitor apps (5M+). **Reference only** — Verified Glam implements via [HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md) and locked [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md) tokens.

**Screenshots:** [docs/reference/competitor-screenshots/](reference/competitor-screenshots/README.md)

---

## 1. Design principles

| Principle | What competitors do | Why it works |
|-----------|---------------------|--------------|
| Soft UI | High border radii, pill buttons, pastel circles | Friendly, feminine, low cognitive load |
| Whitespace | Generous padding; one primary action per screen | Clear hierarchy; fewer mis-taps |
| Flat depth | Thin borders on cards, minimal shadows | Clean, modern; fast to scan |
| Line iconography | 1–2px stroke, single accent color | Consistent with light backgrounds |
| Answer-first | Bold headline → gray subcopy → bottom CTA | Matches onboarding and conversion best practice |
| Carousel discovery | Horizontal feature cards with peek + dots | Surfaces multiple scan types without clutter |

Two visual **families** appear in the screenshot set:

1. **Glam Up (primary):** White background, coral/rose pink accent, script wordmark, 2-tab nav.
2. **Beauty Scanner (alternate):** Teal/green accent, dark processing screen, wireframe face — use for **processing/paywall variants** only.

---

## 2. Color tokens (competitor → semantic → Verified Glam)

Do **not** paste competitor hex into `BMColors` without approval. Use mapping below at implementation time.

| Competitor token | Approx. hex | Semantic role | Verified Glam token |
|------------------|-------------|---------------|---------------------|
| Coral primary | `#FF6B8B` – `#FF7295` | Solid CTAs, active nav, icons | `bmSpecialColor` `#872B3F` |
| Muted rose | `#D66A7A` | Logo, secondary icons | `bmPrimaryColor` `#C79A9A` |
| Pastel fill | `#FFE8EE` – `#FFF0F3` | Icon circles, inactive dots | `#F6E3E3` / 15% `bmPrimaryColor` |
| Sheet row fill | `#FCE4EA` (translucent) | Settings menu pills | `#F6E3E3` or `#FFF7F7` |
| Background | `#FFFFFF` | Cards | White cards on `bmLightScaffoldBackgroundColor` scaffold |
| Headline text | `#1A1A1A` – `#212121` | Titles | `appTextColorPrimary` |
| Body text | `#6B7280` – `#8D8C8C` | Subtitles | `appTextColorSecondary` / `bmGreyColor` |
| Dark processing BG | `#000000` | Processing screen | New sub-theme (not global scaffold) |
| Emerald accent | `#4ADE80` – `#00BFA5` | Scanner progress, paywall PRO | Optional accent for dark screens only |
| Paywall gradient | Purple–blue | Promo modal | RevenueCat promo UI (optional) |

---

## 3. Typography

| Element | Competitor | Verified Glam |
|---------|------------|---------------|
| Wordmark | Script/cursive (“Glam Up”) | **Verified Glam** wordmark TBD — not competitor script |
| Headings | Bold geometric sans, 22–28sp | Open Sans bold, 20–24 (`boldTextStyle`) |
| Body | Regular sans, 14–16sp, gray | Open Sans `primaryTextStyle` |
| Button label | Bold white on pink, 16–18sp | `boldTextStyle` 14–20, white on `bmSpecialColor` |
| Legal / fine print | 10–12sp light gray | Same, bottom of paywall |

---

## 4. Spacing and radii

| Element | Competitor value | Implementation note |
|---------|------------------|---------------------|
| Screen horizontal padding | 20–24px | Match template `16`–`20` padding |
| Card border radius | 20–24px | Feature carousel cards |
| Inner image radius | 12–16px | Aesthetic / look-type photos |
| Primary button radius | 50% of height (pill) | Increase from template `32` to full pill where competitor-shaped |
| List row radius | 10–12px | Onboarding selections |
| Bottom sheet top radius | 20–30px | Settings sheet |
| Progress bar height | 4–6px, rounded caps | Top onboarding bar |
| Icon circle diameter | 120–160px | Empty states, home card hero |

---

## 5. Components

### 5.1 Primary button (pill CTA)

- **Layout:** Full width minus horizontal margin (~20px each side), fixed bottom or in-card.
- **Style:** Solid accent fill, **no** border, white bold label.
- **States:** Disabled = 40% opacity or `bmGreyColor` fill.
- **Examples:** `02-face-analysis-home.png` (“Start scan”), `09-gender.png` (option pills), `20-allow-notifications.png` (“Enable notifications!”).

### 5.2 Secondary button (settings sheet row)

- **Layout:** Full-width row, label left, icon right.
- **Style:** Pale pink background, accent text and icon, pill shape.
- **Example:** `07-settings-sheet.png`.

### 5.3 Selection list (multi-select)

- **Unselected:** White fill, 1px accent border, accent text, empty circle icon left.
- **Selected:** Solid accent fill, white text, white check in filled circle.
- **Radius:** ~12px.
- **Example:** `10-beauty-goals.png`.

### 5.4 Selection list (single-select — gender style)

- **All options styled as solid pills** (competitor treats each as tappable primary).
- **Use when:** Exactly one choice required, no multi-select.
- **Example:** `09-gender.png`.

### 5.5 Feature card (home carousel)

- **Structure:** White card, thin light border, large top illustration (circle + line art), title (+ optional emoji), description, embedded pill CTA.
- **Carousel:** Adjacent card visible ~10–15% width; 3 dots below (active = accent, inactive = faded pastel).
- **Examples:** `02-face-analysis-home.png`, `03-colour-analysis-home.png`.

### 5.6 Aesthetic card (photo carousel)

- **Structure:** White card, **photo** with rounded rect, title, description, “Select” pill.
- **Pagination:** 5–7 dots.
- **Example:** `13-aesthetic-look-type.png`.

### 5.7 Empty state

- **Structure:** Centered illustration in pastel circle, bold headline, gray subcopy, optional bottom pill CTA.
- **Example:** `05-scans-empty.png`.

### 5.8 Top progress bar

- **Position:** Below status bar, full width with side margin.
- **Track:** Pale accent; **fill:** solid accent; rounded ends.
- **Progress:** ~20% early steps, ~80–90% before rating/notifications.
- **Examples:** `10-beauty-goals.png`, `21-leave-a-review.png`.

### 5.9 Bottom navigation (competitor)

- **Tabs:** 2 — Home, Scans.
- **Style:** White bar, thin top border, icon + label; active = accent, inactive = faded pink/gray.
- **Verified Glam:** Document as **target UX**; template still has 5 tabs until approved ([HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md)).

### 5.10 Bottom sheet

- **Chrome:** White, top handle (40×4 gray pill), top corners 24px+.
- **Content:** Vertical stack of secondary pill buttons.
- **Example:** `07-settings-sheet.png`.

### 5.11 Language row

- **Row:** Rounded gray/off-white background, circular flag, label, radio circle right.
- **Ignore:** Third-party green INSTALL ad styling (`22-language.png`).

### 5.12 Paywall — dark comparison

- **Background:** Black.
- **Content:** Feature table (Free vs PRO), toggle for trial, plan cards with border selection, pill CTA, legal text, trust row (“No payment now” + shield).
- **Example:** `23-paywall-dark.png`.

### 5.13 Paywall — promo overlay

- **Modal:** Gradient purple/blue, rounded 24px+, gift 3D art, countdown boxes, strikethrough price, red-orange gradient CTA.
- **Example:** `24-paywall-promo-overlay.png`.

### 5.14 Processing screen (dark)

- **Background:** Black.
- **Hero:** Green wireframe face mesh, corner brackets, horizontal scan line animation.
- **Progress:** Pill bar, accent fill ~30–40% while indeterminate.
- **Copy:** Split title color (“Beauty” white + “Scanner” green).
- **Reference:** `alt-02-face-score-onboarding.png` aesthetic + separate processing variants in Beauty Scanner apps.

### 5.15 Camera / scan frame

- **Overlay:** Viewfinder corner brackets, optional face oval guide.
- **Example:** `08-scan-face-camera.png`.

---

## 6. Iconography

| Icon | Style | Usage |
|------|-------|-------|
| Settings gear | Outline, accent | Header right |
| Home | Outline house | Bottom nav |
| Scans | Face in viewfinder brackets | Bottom nav, empty state |
| Share | Curved arrow | Settings sheet |
| Copy / invite | Double square | Settings sheet |
| Envelope | Outline | Support |
| Instagram | Camera outline | Social link |
| Padlock | Outline | Privacy |
| Checkmark | In circle | Selected list row |
| Back | Chevron `<` accent | Onboarding |

**Construction rules:**

- Stroke width: 1.5–2dp equivalent.
- Corner style: rounded caps/joins.
- No mixed filled/outlined sets on same screen.

**Signature motif:** Face line art inside **pastel circle** + **four corner brackets** (scan/viewfinder). Reuse for home cards, empty states, splash marketing — custom SVG/Lottie later.

---

## 7. Imagery rules

| Type | Treatment | Where |
|------|-----------|-------|
| Walkthrough heroes | Full-bleed photography | **Template only** (`model_*.jpg`) — not competitor style |
| Feature marketing | Line illustration in circle | Home carousel |
| Look / aesthetic | Real photo, rounded rect | Onboarding carousel |
| Products | Product shots or icons | Favorite products step |
| Paywall | 3D gift, crowns | Promo overlay only |
| Processing | Wireframe mesh | Dark full-screen |

---

## 8. Screen-by-screen notes

Linked files live under [reference/competitor-screenshots/](reference/competitor-screenshots/README.md).

### Entry and home

| Screenshot | Key UI | Verified Glam mapping |
|------------|--------|------------------------|
| `01-app-opening.png` | Logo, settings, headline, carousel | `BMHomeFragment` + head component |
| `02-face-analysis-home.png` | Facial Analysis card | Feature: face analysis |
| `03-colour-analysis-home.png` | Color Analysis card | Feature: color analysis |
| `05-scans-empty.png` | Empty scans + CTA | `BMAppointmentFragment` repurpose |

### Settings and scan

| Screenshot | Key UI | Verified Glam mapping |
|------------|--------|------------------------|
| `07-settings-sheet.png` | Share, invite, support, legal | `BMBottomSheet` / `BMMoreFragment` |
| `08-scan-face-camera.png` | Camera UI | New `PhotoUploadScreen` |
| `16-upload-or-take-pic.png` | Source picker | Scan pipeline |
| `17-upload-scan-rules.png` | Guidelines | Photo guidelines screen |

### Onboarding questionnaire

| Screenshot | Key UI | Verified Glam mapping |
|------------|--------|------------------------|
| `09-gender.png` | Pill single-select | Questionnaire step |
| `10-beauty-goals.png` | Multi-select rows | Goals step |
| `11-skin-type.png` / `12-skin-types.png` | Skin selection | Skin type steps |
| `13-aesthetic-look-type.png` | Photo carousel | Aesthetic step |
| `15-favorite-products.png` | Product prefs | Preferences step |

### Funnel completion

| Screenshot | Key UI | Verified Glam mapping |
|------------|--------|------------------------|
| `18-setting-everything.png` | Loader | Processing setup |
| `19-account-ready.png` | Success cards | `BMWelcomeScreen` |
| `20-allow-notifications.png` | Permission CTA | `BMEnableNotificationScreen` |
| `21-leave-a-review.png` | Rating prompt | New screen (late funnel) |
| `22-language.png` | Language list | i18n settings |

### Monetization

| Screenshot | Key UI | Verified Glam mapping |
|------------|--------|------------------------|
| `23-paywall-dark.png` | Feature matrix + plans | RevenueCat primary |
| `24-paywall-promo-overlay.png` | Limited-time offer | Optional promo |

### Alternate (teal)

| Screenshot | Key UI | Verified Glam mapping |
|------------|--------|------------------------|
| `alt-01-facial-trait-onboarding.png` | Illustration onboarding | Optional marketing only |
| `alt-02-face-score-onboarding.png` | Score preview | Golden ratio feature copy |

---

## 9. Patterns not obvious from “buttons and corners”

| Pattern | Detail |
|---------|--------|
| Information hierarchy | One H1, one supporting paragraph, one primary CTA per step |
| Progress persistence | Top bar advances across questionnaire; back chevron always visible |
| Trust signals | Shield + “No payment now” on paywall; star rating on review step |
| Urgency | Countdown on promo paywall; “BEST PRICE” badge on annual plan |
| Social proof | Store review screen after value demonstration |
| Referral | Invite code in settings sheet |
| Badges | HOT / NEW on feature cards — use sparingly |
| Emoji in titles | Optional warmth on feature names |
| Ads | Banner at bottom of some screens — replace with **AdMob** slots per product spec, not competitor green CTA style |
| Accessibility | Large pill tap targets (min 48dp height); sufficient contrast on CTA |

---

## 10. Anti-patterns (do not ship)

1. **Brand theft:** “Glam Up” name, script logo, or identical screenshot recreation.
2. **Wrong palette on shell:** Coral pink `#FF6B8B` on auth/walkthrough without hybrid approval.
3. **Replacing walkthrough photos** with competitor line-art slides.
4. **Copying ad network UI** (green INSTALL buttons) as if in-app brand.
5. **Mixing families:** Teal onboarding + pink home without intentional dual-theme design.
6. **Heavy shadows** on cards where competitor uses borders only.
7. **Pixel-perfect clone** of paywall legal copy or pricing from competitor.

---

## 11. Related documentation

- [HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md) — what to keep vs adopt
- [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md) — Beauty Master locked shell
- [TEMPLATE_TO_VERIFIED_GLAM_MAP.md](TEMPLATE_TO_VERIFIED_GLAM_MAP.md) — screen mapping
- [reference/competitor-screenshots/README.md](reference/competitor-screenshots/README.md) — image index

*Last updated: competitor design memory documentation phase.*
