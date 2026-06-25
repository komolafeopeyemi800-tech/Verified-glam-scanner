# Result UI — competitor reference (Verified Glam)

**Purpose:** Durable design memory for **analysis result screens** (Phase 6). Competitor apps with heavy daily use never ship icon-only result heroes — they show the user's real face with analysis overlays plus structured data panels.

**Status:** UI implemented with local mock fallback (`vg_mock_results.dart`, `kVGUseMockAnalysis`). Production payloads from Supabase Edge Function `analyze-scan` (OpenAI vision); UI shapes stay the same.

**Screenshot archive:** [`docs/reference/competitor-results/README.md`](reference/competitor-results/README.md)

**Related:** [HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md), [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md), [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) Phase 6.

---

## Current app gap

Photo-hero result UIs are **implemented (mock)** for all 10 active features under [`lib/screens/scan/results/`](../lib/screens/scan/results/) with shared widgets in [`lib/components/vg/results/`](../lib/components/vg/results/). Competitor PNGs in [`docs/reference/competitor-results/`](reference/competitor-results/README.md) are layout reference only — overlays are drawn with `CustomPaint` on the user's uploaded photo.

**Still future:** Real landmark data from Convex/OpenAI; replace mock seed with API payloads.

---

## Section A — Non-negotiable rules

| Rule | Verified Glam adaptation |
|------|-------------------------|
| Always show **user photo** on result screen | From scan `photoPath`; circular or rounded-rect crop; minimum hero height ~220dp |
| **No icon-only** result hero | Icons only in small chips or list rows — never replace the face |
| Overlays use **CustomPaint + Stack** | Do not bake competitor PNG overlays into assets; draw lines, dots, regions in Flutter |
| Overlay stroke colors | `bmSpecialColor` / white on a semi-transparent dark scrim; **green mesh only on processing screen**, not on final results |
| Copy is **original** | Patterns from competitors; wording from [`lib/utils/vg_copy.dart`](../lib/utils/vg_copy.dart) |
| Competitor screenshots = **layout inspiration** | Same policy as [HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md) — no competitor names, coral pink, or bundled competitor art |
| Anti-patterns archived | See `*-icon-sample-do-not-use.png` in [competitor-results/](reference/competitor-results/README.md) |

---

## Section B — Overlay vocabulary (Phase 6 widget names)

Reusable building blocks to implement under `lib/components/vg/results/` (names are prescriptive; **not built yet**):

| Building block | What competitors do | VG token / implementation notes |
|----------------|---------------------|--------------------------------|
| `VGFacePhotoHero` | Large centered user image | Rounded corners 16–24px; optional dark scrim (`Colors.black` @ 30–40%) behind overlays |
| `VGLandmarkMesh` | Triangulated mesh or dot network on face | Semi-transparent strokes; simplified mesh from landmark JSON (not full 468-point render required at v1) |
| `VGProportionGrid` | Vertical midline + horizontal facial thirds | White 1px lines @ 40% opacity |
| `VGRegionOutline` | Colored outline on eyes / nose / mouth / cheeks | Per-region tint from `bmPrimaryColor` variants (not competitor blue/green) |
| `VGCalloutLabel` | Pill with leader line, e.g. "Eyes symmetry 95%" | White card, burgundy text; PASS = success green tint; attention = rose for below-threshold |
| `VGRatioBadge` | "1.62 / 1.618 [PASS]" on face edge | Small rounded rect anchored left/right of hero |
| `VGScoreRing` | Large % in circle (harmony, golden ratio) | Evolve existing `VGScoreDisplay` with photo behind ring |
| `VGMatchRow` | Thumbnail + name + % + trait bullets | Celebrity lookalike list |
| `VGSwatchRow` | Skin / Hair / Eyes color squares | Color analysis; tap to highlight sample region on face |
| `VGLeaderLine` | Line from label to facial zone | Used by symmetry, face reading, best-face-part |
| `VGPassFailChip` | PASS / ATTENTION on ratio rows | Burgundy scaffold; green only for explicit pass state |

**Composition pattern:** `Stack` → `VGFacePhotoHero` → overlay painters → `Positioned` callouts → scrollable data panel below hero.

---

## Section C — Per-feature result layout templates (all 11)

Each row maps a [`VGFeatureTypes`](../lib/utils/vg_constants.dart) constant to a layout template. Reference PNGs are in [competitor-results/README.md](reference/competitor-results/README.md).

### `FACE_BEAUTY_ANALYSIS`

| Aspect | Spec |
|--------|------|
| **Layout** | Full-width passport photo hero → editorial guide overlays + leader-line labels → white report card (Beauty Score /100, five subscores, disclaimer) |
| **Overlays** | `VGBeautyGuideOverlay` (dashed symmetry + horizontals + brow/nose/jaw curves); `VGBeautyAnnotationOverlay` (text-only pills + leader lines) |
| **Data panel** | `VGBeautyReportCard`: `beautyScore`, `subscores` (symmetry, featureBalance, skinQuality, youthfulCues, overallBeauty) |
| **Mock / API payload** | `beautyScore`, `subscores`, `annotations[]`, `guides` in `vg_mock_results.dart` |
| **Anti-pattern** | `VGLandmarkMeshPainter` on final result (processing-only aesthetic) |

### `COLOR_ANALYSIS`

| Aspect | Spec |
|--------|------|
| **Layout** | Photo hero → sampling highlight on cheek → `VGSwatchRow` (Skin, Hair, Eyes) → season name → palette grid |
| **Overlays** | Plus/dot on active sample region; selected category border on face |
| **Data panel** | Season type, palette hex swatches, wear recommendations |
| **Reference PNGs** | `color-analysis-swatch-01.png` … `03.png`, `color-analysis-result-01.png` |

### `CELEBRITY_LOOKALIKE`

| Aspect | Spec |
|--------|------|
| **Layout** | Vertical: photo hero with mesh → Celebrity Match badge → 3 match cards → share/referral bar |
| **Overlays** | `VGCelebrityFaceMeshOverlay` — static green wireframe mesh + optional scan-frame side bars on result hero |
| **Data panel** | Match name, similarity %, features/why line; celebrity thumbnail via `imageAsset` |
| **Share** | `VGShareResultBar` with Unilink referral URL, progress (3 friends), redeem bonus scans |
| **Reference PNGs** | `celebrity-match-light-01.png`, `celebrity-match-dark-01.png` |

### `FACIAL_SYMMETRY`

| Aspect | Spec |
|--------|------|
| **Layout** | Photo hero → per-region symmetry pills with leader lines → decimal overall bar → Fotor-inspired metrics card (2×3 subscores) |
| **Overlays** | `VGSymmetryGridOverlay` (center + side verticals, landmark horizontals), `VGRegionOutlinePainter` (color zones), `VGSymmetryCalloutOverlay` (eyes, nose, mouth, cheeks %) |
| **Data panel** | `overallSymmetryScore` (decimal), `subscores` (beauty, cuteness, skin smoothness, handsomeness, face shape, facial symmetry); `measurements` object stored for future API |
| **Deferred** | Suggested facial balance exercises (threshold-gated tips when score below average) |
| **Reference PNGs** | `facial-symmetry-result-01.png`, `facial-symmetry-overlay-01.png`, `facial-symmetry-thirds-01.png` |
| **Anti-pattern** | `facial-symmetry-icon-sample-do-not-use.png` |

### `GOLDEN_RATIO`

| Aspect | Spec |
|--------|------|
| **Layout** | Photo hero with measurement overlay → Golden Ratio Face Report card |
| **Overlays** | `VGGoldenRatioMeasurementOverlay` — white landmarks, red lines/brackets, pass/fail callouts, bottom score bar |
| **Data panel** | 6 ratios with Δ from ideal, score /20 each, Golden Ratio Index /100, rating band (Excellent/Good/Fair/Poor) |
| **Share** | `VGShareResultBar` via scaffold with score + index message |
| **Reference PNGs** | Competitor measurement overlay, metric callout cards, Fotor Golden Ratio Face Report |

### `GLOW_UP_GUIDE`

| Aspect | Spec |
|--------|------|
| **Layout** | Smaller photo strip (optional) → 7-day card list (primary content) |
| **Overlays** | Minimal — photo sets context only |
| **Data panel** | Day 1–7 tasks, product/style suggestions |
| **Reference PNGs** | Infer from home carousel patterns in [competitor-screenshots/](reference/competitor-screenshots/README.md); no dedicated result PNG in archive |

### `BEAUTY_TIPS`

| Aspect | Spec |
|--------|------|
| **Layout** | Passport photo hero → `VGBeautyTipsReportCard` (findings + grouped tips + disclaimers) |
| **Payload** | `spots[]` per blemish (id, categoryId, label, anchor, severity); `findings[]` aggregated by category with `spotCount`; `annotations[]` derived for overlay |
| **Overlays** | `VGSkinConcernOverlay`: 8–14+ per-spot labels at anchor Y, collision nudging, leader lines to exact dots (Pimple, Dark spot, Bump, etc.) |
| **Data panel** | Per finding: category + area count when &gt;1 + severity chip; 4 tip cards; per-tip + global disclaimers |
| **Share** | `VGCopy.beautyTipsShareMessage` — spot count + top label summary |
| **Reference PNGs** | `face-beauty-editorial-01.png` (region-labeled editorial style) |

### `BEST_FACE_PART`

| Aspect | Spec |
|--------|------|
| **Layout** | Photo hero + highlight ring on standout region → short "why" card |
| **Overlays** | `VGRegionOutline` glow on winning feature; single `VGCalloutLabel` |
| **Data panel** | Feature name, score, one-line explanation |
| **Reference PNGs** | `attractiveness-gauge-01.png`, `face-beauty-score-example-01.png`, `face-beauty-editorial-01.png` |

### `BEAUTY_SCORE_SHOWDOWN`

| Aspect | Spec |
|--------|------|
| **Layout** | Photo hero with mesh + score badge → gradient podium (top 3) → your rank card |
| **Overlays** | `VGShowdownFaceMeshOverlay` (white mesh), `VGShowdownScoreBadge` (decimal /10 ring) |
| **Data panel** | Podium scores, `#N of total`, percentile pill, engagement note, community avg |
| **Share** | `VGShareResultBar` via scaffold with rank-aware message |
| **Reference PNGs** | `attractiveness-gauge-01.png`, `attractiveness-test-01.png`, challenge leaderboard reference |

### `FACIAL_RESEMBLANCE`

| Aspect | Spec |
|--------|------|
| **Layout** | Single two-person photo hero → contour comparison text → dynamic score badge → explanation |
| **Input rule** | Exactly **two faces in one photo** (couples, friends, siblings selfie) — enforced at upload |
| **Overlays** | `VGFaceComparisonOverlay` — pink Face 1 + blue Face 2 contour traces with labels |
| **Data panel** | Dynamic score label (Sibling / Couple / Friend), similarity /100, shared traits |
| **Guidelines** | Feature-specific Do/Avoid + `face_comparison_good_bad.png` |
| **Share** | `VGShareResultBar` via `VGResultScaffold` (all features) |

### `FACE_READING`

| Aspect | Spec |
|--------|------|
| **Layout** | Photo hero with scan box → overall /10 report card with appearance + trait bars |
| **Overlays** | `VGAttractivenessScanBoxOverlay` — white corner brackets + mesh clipped inside box |
| **Data panel** | Overall score ring (`8.7/10`), tier label, facial age pill, 6 appearance metrics, 4 trait metrics |
| **Share** | `VGShareResultBar` via scaffold with score + tier message |
| **Reference PNGs** | Competitor scan-box hero, split metrics panel, fotor-style subscore grid |

---

## Section D — Data model notes (implement later, not now)

Planned extensions when Phase 6 coding starts:

### `VGScanResult`

- Add optional `photoPath` (local file path; persist with scan history in `VGScanHistoryStore`).
- Pass `photoPath` from [`vg_processing_screen.dart`](../lib/screens/scan/vg_processing_screen.dart) when building the result.

### Mock payloads (`vg_mock_results.dart`)

Add overlay-friendly fields per feature, for example:

```json
{
  "landmarks": [{ "x": 0.5, "y": 0.3, "id": "left_eye" }],
  "regions": [{ "id": "eyes", "symmetry": 0.95 }],
  "ratios": [{ "name": "lip_width", "value": 1.62, "ideal": 1.618, "pass": true }],
  "matches": [{ "name": "...", "percent": 87, "traits": ["..."] }]
}
```

Coordinates should be **normalized 0–1** relative to face bounding box for responsive `CustomPaint`.

### Results routing

- [`vg_results_screen.dart`](../lib/screens/scan/vg_results_screen.dart) becomes a router.
- Per-feature widgets under `lib/screens/scan/results/` (folder per roadmap; currently inline).
- Shared overlay widgets under `lib/components/vg/results/`.

### Reuse existing components

- `VGScoreDisplay`, `VGAnalysisCard`, `VGRecommendationCard` move **below** the photo hero, not as the hero itself.
- `VGAdBanner` stays at bottom of scroll per monetization rules.

---

## Section E — Implementation order (after this doc)

1. Extend `VGScanResult` + mock JSON with `photoPath` and overlay fields.
2. Build shared overlay widgets (`VGFacePhotoHero`, `VGCalloutLabel`, …).
3. Rebuild per-feature result screens (recommended order):
   - `FACE_BEAUTY_ANALYSIS`
   - `CELEBRITY_LOOKALIKE`
   - `COLOR_ANALYSIS`
   - `FACIAL_SYMMETRY`
   - `GOLDEN_RATIO`
   - Remaining six features
4. Wire real Convex/OpenAI payloads (Phase 5) into same UI shapes.

---

## Verification checklist (Phase 6 exit)

- [ ] Every feature type shows **user photo** as hero (min ~220dp).
- [ ] Every feature type has **at least one overlay** (mesh, grid, callout, ring, or swatch) — not text-only.
- [ ] No icon-only result heroes in production.
- [ ] Copy from `vg_copy.dart` only; BMColors tokens only.
- [ ] Competitor PNGs remain in `docs/reference/` only.

*Created: competitor result UI design memory pass (documentation only).*
