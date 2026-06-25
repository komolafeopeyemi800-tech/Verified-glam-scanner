
# Verified Glam — Development roadmap (Flutter)

Phased plan for building **Verified Glam** inside the **Beauty Master** Flutter template. No React Native rewrite unless explicitly decided.

**Prerequisites:** Read [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md) and [TEMPLATE_TO_VERIFIED_GLAM_MAP.md](TEMPLATE_TO_VERIFIED_GLAM_MAP.md).

---

## Principles

1. **Shell first** — Keep UI components, colors, walkthrough photos, and navigation chrome.
2. **Content second** — Strings, mock data, and screen destinations.
3. **Backend third** — Supabase (Auth, Postgres, Storage, Edge Functions) + OpenAI + monetization SDKs.
4. **No API keys in the client** — OpenAI only via Supabase Edge Functions.
5. **UI changes require approval** — Default PR scope is content/data unless design doc is updated.

---

## Phase 0 — Documentation (complete)

- [x] `docs/DESIGN_SYSTEM_LOCKED.md`
- [x] `docs/VERIFIED_GLAM_PRODUCT.md`
- [x] `docs/TEMPLATE_TO_VERIFIED_GLAM_MAP.md`
- [x] `docs/source/VERIFIED_GLAM_FULL_SPEC.md`
- [x] `docs/DESIGN_SYSTEM_COMPETITOR_REFERENCE.md`
- [x] `docs/HYBRID_DESIGN_RULES.md`
- [x] `docs/reference/competitor-screenshots/` archive
- [x] `.cursor/rules/verified-glam.mdc`

---

## Phase 1 — Rebrand and copy (week 1)

**Goal:** App feels like Verified Glam while looking identical structurally.

| Task | Files / areas |
|------|----------------|
| App display name | `lib/utils/BMConstants.dart`, Android label |
| Splash tagline | `BMSplashScreen.dart` |
| Walkthrough text only | `BMDataGenerator.dart` → `getWalkThroughList()` |
| Remove “Beauty Master” / “OraPay” upsell copy | `BMPurchaseMoreScreen.dart` (placeholder text) |
| Constants file | New `lib/utils/vg_constants.dart` — app name, slogans, support email |

**Exit criteria:** Walkthrough still shows same 3 model images; copy matches Verified Glam carousel.

---

## Phase 2 — Onboarding questionnaire (weeks 2–3)

**Goal:** 9-step profile collection per full spec §5.

| Task | Approach |
|------|----------|
| Clone step UI from | `BMRegisterScreen`, `BMEnableNotificationScreen` (`upperContainer` pattern) |
| New screens | Age, gender, goals, concerns, product prefs, skin type, ethnicity, aesthetic |
| Progress bar | Top of each step (~11% increments) |
| Persistence | Local first (`shared_preferences` / existing `nb_utils` prefs); Convex later |
| Rating step | In-app review prompt |
| Profile ready | Reuse `BMWelcomeScreen` content structure |
| Trim flow | Skip or repurpose `BMEnableLocationScreen` |

**Exit criteria:** New user can complete questionnaire end-to-end with dummy “Continue” saving to local store.

---

## Phase 3 — Home and features (week 4) — complete

**Goal:** Salon UI becomes scan feature discovery.

| Task | Status |
|------|--------|
| Feature cards with `featureType`, badges | Done |
| Home carousel + grid | Done |
| 4-tab nav (Home, Scan, Explore, Guide) | Done |
| Settings sheet via header gear | Done |

**Exit criteria:** Home shows all 11 features; tapping navigates to scan flow.

---

## Phase 4 — Scan flow UI (weeks 5–6) — complete

**Goal:** End-to-end UI without real AI.

| Task | Status |
|------|--------|
| Guidelines + good/bad example tiles | Done — add JPGs per `docs/assets/GUIDELINE_IMAGE_PROMPTS.md` |
| Upload screen | Done — `image_picker` + line-art placeholder |
| Processing screen | Done — dark wireframe animation |
| Results components | Done — `VGScoreDisplay`, `VGAnalysisCard`, `VGRecommendationCard` |
| Paywall UI (mock) | Done — dark comparison + promo sheet + success screen |
| Mock subscription store | Done — `VGSubscriptionStore` (RevenueCat in Phase 7) |
| History reopen | Done — Scan tab taps saved results |

**Exit criteria:** Full UI path works with mock data; Pro gating blocks premium features until mock purchase.

---

## Phase 5 — Supabase and OpenAI (in progress)

**Goal:** Real analysis via Supabase backend.

| Task | Detail |
|------|--------|
| Supabase project | Auth (email + Google), `profiles`, `scans`, `scan-photos` bucket — see [SUPABASE_SETUP.md](SUPABASE_SETUP.md) |
| Edge Function | `analyze-scan` — vision + JSON payloads per `VGFeatureTypes` |
| Flutter client | `supabase_flutter`, `VGAnalysisService`, repositories under `lib/services/supabase/` |
| Image upload | `VGSupabaseStorageService` → Edge Function signed URL |

**Exit criteria:** Signed-in user runs Beauty Tips + Face Beauty E2E with cloud history.

**Status:** Schema, Edge Function, and Flutter wiring landed; requires project credentials + `supabase db push` + `functions deploy`.

---

## Phase 6 — Remaining features (weeks 9–10)

**Status (May 2026):** Photo-hero result UIs + local mock payloads implemented for 10 active features. `kVGLocalDevMode` in `vg_constants.dart` unlocks all features without paywall during local build. Standout Feature (`BEST_FACE_PART`) removed from catalog; legacy history still renders. Set `kVGLocalDevMode = false` before RevenueCat production.

**Prerequisites (design memory — done):**

- [RESULT_UI_COMPETITOR_REFERENCE.md](RESULT_UI_COMPETITOR_REFERENCE.md) — photo hero + overlay rules, per-feature layout templates, widget vocabulary
- [docs/reference/competitor-results/](reference/competitor-results/README.md) — archived competitor result screenshots

Implement result UIs for each `VGFeatureTypes` constant per spec §9 and the result UI reference:

- User **photo hero** from scan `photoPath` on every result screen (not text-only cards)
- At least one **face overlay** per feature (`CustomPaint` + `Stack`: mesh, grid, callouts, rings, or swatches)
- Shared widgets: `VGFacePhotoHero`, `VGCalloutLabel`, etc. (see reference doc Section B)
- Per-feature screens under `lib/screens/scan/results/`; extend `VGScanResult` + mock JSON with overlay fields

Features: face beauty analysis, color analysis, celebrity lookalike, facial symmetry, golden ratio, glow up guide, beauty tips, best face part, beauty score showdown, facial resemblance, face reading.

**Exit criteria:** All 11 feature types show **photo + overlay + structured data panel**; no icon-only result heroes; copy from `vg_copy.dart`; colors from `BMColors`.

---

## Phase 7 — Monetization (week 11)

| Task | SDK |
|------|-----|
| RevenueCat | Replace mock `VGSubscriptionStore` purchase/restore |
| AdMob | Replace `VGAdBanner` placeholder + interstitial stub |
| Paywall screen | **UI done** — wire RevenueCat packages |
| Feature matrix | Enforce free vs pro per `FEATURES` constants |

**Exit criteria:** Free user sees interstitial before results; Pro user does not.

---

## Phase 8 — Polish and Play Store (week 12)

| Task | Detail |
|------|--------|
| Challenge push (Parts 4–7) | FCM job queue, pref-time scheduling, share PNG — see [FCM_PUSH_SETUP.md](FCM_PUSH_SETUP.md) and [PRE_LAUNCH_CHECKLIST.md](PRE_LAUNCH_CHECKLIST.md) |
| Push cron + migrations 005–008 | Manual Dashboard; run `tools\verify-push-readiness.ps1` |
| §17 engagement pushes | Inactive user / weekly scan — post-launch |
| Settings | Account delete, legal WebViews, subscription manage |
| Assets | Icon, feature graphic, screenshots (use locked brand colors) |
| Privacy / terms | Hosted URLs |
| QA | [PRE_LAUNCH_CHECKLIST.md](PRE_LAUNCH_CHECKLIST.md) |
| Internal testing | Play Console internal track |

---

## Ongoing / post-launch

- Leaderboard refresh (beauty showdown)
- Referral / invite code
- iOS port (optional, not in current scope)
- Analytics: `VGAnalyticsService` wired; expand paywall/ad events in Phase 7

---

## Risk register

| Risk | Mitigation |
|------|------------|
| Spec assumes React Native | This roadmap uses Flutter; full spec is reference only |
| Template tab 1 is upsell | Repurpose early in Phase 3 |
| OpenAI cost / latency | Rate limits, loading UX, error retry |
| Play policy on face photos | Clear privacy policy + on-device consent copy |
| Walkthrough assets not on-brand | Keep until Verified Glam photography supplied |

---

## Tracking

Update checkboxes in PR descriptions by phase. Link PRs to phase number in commit messages, e.g. `feat(vg): phase-3 home feature grid`.

---

## Related docs

- [VERIFIED_GLAM_PRODUCT.md](VERIFIED_GLAM_PRODUCT.md)
- [source/VERIFIED_GLAM_FULL_SPEC.md](source/VERIFIED_GLAM_FULL_SPEC.md)
