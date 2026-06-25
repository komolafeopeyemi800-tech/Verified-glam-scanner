# Competitor result / output screenshot archive

Persistent copies of **analysis result screens** from competitor beauty-scanner apps (Glam Up category). Used as **layout and overlay inspiration only** — not for pixel-perfect cloning or app bundle assets.

**Related docs:** [RESULT_UI_COMPETITOR_REFERENCE.md](../../RESULT_UI_COMPETITOR_REFERENCE.md) (master spec), [HYBRID_DESIGN_RULES.md](../../HYBRID_DESIGN_RULES.md), [DESIGN_SYSTEM_LOCKED.md](../../DESIGN_SYSTEM_LOCKED.md).

**Onboarding / home / scan flow refs** live in [`../competitor-screenshots/`](../competitor-screenshots/README.md).

**Source:** User-provided screenshots (May 2026), copied from Cursor workspace storage.

---

## Index

| File | Competitor pattern | Overlay / UI elements | Maps to `VGFeatureTypes` |
|------|-------------------|----------------------|--------------------------|
| [face-beauty-analysis-result-01.png](face-beauty-analysis-result-01.png) | Full result with photo hero + metrics | Score bar, feature list, face crop | `FACE_BEAUTY_ANALYSIS` |
| [face-beauty-mesh-labels-01.png](face-beauty-mesh-labels-01.png) | Landmark mesh + metric pills on face | Green/cyan mesh, labeled regions | `FACE_BEAUTY_ANALYSIS` |
| [face-beauty-landmark-mesh-02.png](face-beauty-landmark-mesh-02.png) | Dot network / triangulated mesh | Landmark dots, connecting lines | `FACE_BEAUTY_ANALYSIS` |
| [face-beauty-score-grid-01.png](face-beauty-score-grid-01.png) | Proportion grid + ratio callouts | White grid, midline, PASS/FAIL badges | `FACE_BEAUTY_ANALYSIS`, `GOLDEN_RATIO` |
| [face-beauty-radar-dashboard-01.png](face-beauty-radar-dashboard-01.png) | Multi-metric radar + progress bars | Radar chart, horizontal bars | `FACE_BEAUTY_ANALYSIS` (detailed breakdown) |
| [face-beauty-artistic-overlay-01.png](face-beauty-artistic-overlay-01.png) | Stylized face illustration overlay | Decorative lines on portrait | Reference only (tone) |
| [face-beauty-score-example-01.png](face-beauty-score-example-01.png) | Editorial score breakdown | Lip/eye ratings, text callouts | `FACE_BEAUTY_ANALYSIS`, `BEST_FACE_PART` |
| [face-beauty-editorial-01.png](face-beauty-editorial-01.png) | Magazine-style feature ratings | Region labels, numeric scores | `BEST_FACE_PART`, `BEAUTY_TIPS` |
| [face-beauty-analysis-icon-sample-do-not-use.png](face-beauty-analysis-icon-sample-do-not-use.png) | **Anti-pattern:** icon-only result | No user photo — **do not ship** | — |
| [facial-symmetry-result-01.png](facial-symmetry-result-01.png) | Symmetry result summary | Overall % + region breakdown | `FACIAL_SYMMETRY` |
| [facial-symmetry-overlay-01.png](facial-symmetry-overlay-01.png) | Midline + colored region outlines | Per-region symmetry % pills | `FACIAL_SYMMETRY` |
| [facial-symmetry-thirds-01.png](facial-symmetry-thirds-01.png) | Horizontal thirds + landmark labels | Tr/G/Sn/Me dots, third lines | `FACIAL_SYMMETRY`, `FACE_BEAUTY_ANALYSIS` |
| [facial-symmetry-icon-sample-do-not-use.png](facial-symmetry-icon-sample-do-not-use.png) | **Anti-pattern:** icon-only | No photo hero — **do not ship** | — |
| [golden-ratio-result-01.png](golden-ratio-result-01.png) | Golden ratio result screen | Spiral/grid + harmony score | `GOLDEN_RATIO` |
| [golden-ratio-spiral-01.png](golden-ratio-spiral-01.png) | Fibonacci spiral on face | Spiral overlay, symmetry card | `GOLDEN_RATIO` |
| [golden-ratio-measurements-01.png](golden-ratio-measurements-01.png) | Ratio measurement rows | Distance ratios, pass/fail | `GOLDEN_RATIO` |
| [golden-ratio-harmony-cards-01.png](golden-ratio-harmony-cards-01.png) | Harmony score cards | Large % ring, ratio list | `GOLDEN_RATIO` |
| [color-analysis-swatch-01.png](color-analysis-swatch-01.png) | Face + Skin/Hair/Eyes swatches | Tap dot on cheek, swatch row | `COLOR_ANALYSIS` |
| [color-analysis-swatch-02.png](color-analysis-swatch-02.png) | Season palette grid | Swatches + season label | `COLOR_ANALYSIS` |
| [color-analysis-swatch-03.png](color-analysis-swatch-03.png) | Color category selection | Selected chip border on face | `COLOR_ANALYSIS` |
| [color-analysis-result-01.png](color-analysis-result-01.png) | Full color analysis output | Photo + palette + recommendations | `COLOR_ANALYSIS` |
| [celebrity-match-light-01.png](celebrity-match-light-01.png) | Your photo + 3 match rows | Thumbnail, %, trait bullets | `CELEBRITY_LOOKALIKE` |
| [celebrity-match-dark-01.png](celebrity-match-dark-01.png) | Dark theme celebrity match | Same layout, dark scaffold | `CELEBRITY_LOOKALIKE` |
| [attractiveness-gauge-01.png](attractiveness-gauge-01.png) | Circular photo + gauge rings | Attractiveness / potential rings | `BEAUTY_SCORE_SHOWDOWN`, `BEST_FACE_PART` |
| [attractiveness-test-01.png](attractiveness-test-01.png) | Score rings on portrait | Dual ring scores | `BEAUTY_SCORE_SHOWDOWN` |
| [multi-feature-dashboard-collage.png](multi-feature-dashboard-collage.png) | Multi-feature results collage | Various overlay types combined | All features (overview) |
| [reference-notes-collage.png](reference-notes-collage.png) | Annotated reference collage | Product-owner notes | Planning reference |

---

## Anti-patterns (filename suffix `do-not-use`)

Files marked `*-icon-sample-do-not-use.png` show **icon-only** or illustration-only results with no user photo. Verified Glam Phase 6 must **never** use these as the result hero pattern. See [RESULT_UI_COMPETITOR_REFERENCE.md](../../RESULT_UI_COMPETITOR_REFERENCE.md) Section A.

---

## Usage rules

1. **Legal:** Inspiration only; no competitor branding, logos, or exact copy in the app.
2. **Brand:** Implement overlays with `BMColors` (`bmSpecialColor`, `bmPrimaryColor`, white strokes) — not competitor green mesh on result screens (green reserved for processing screen per hybrid rules).
3. **Assets:** These PNGs stay in `docs/` only — never copy into `images/` or the Flutter asset bundle.
4. **Copy:** All user-facing strings from [`lib/utils/vg_copy.dart`](../../../lib/utils/vg_copy.dart).

*Archived: competitor result UI design memory pass (documentation only).*
