# Competitor screenshot archive

Persistent copies of competitor app UI (Glam Up / beauty-scanner category, 5M+ installs). Used as **visual reference only** — not for pixel-perfect cloning. See [DESIGN_SYSTEM_COMPETITOR_REFERENCE.md](../../DESIGN_SYSTEM_COMPETITOR_REFERENCE.md) and [HYBRID_DESIGN_RULES.md](../../HYBRID_DESIGN_RULES.md).

**Result / analysis output screens** (photo hero + face overlays + score panels) are archived separately in [`../competitor-results/`](../competitor-results/README.md) with the master spec [RESULT_UI_COMPETITOR_REFERENCE.md](../../RESULT_UI_COMPETITOR_REFERENCE.md). *This folder covers onboarding, home, scan pipeline, settings, and paywall flows.*

**Source:** User-provided screenshots (May 2026). Original filenames used `[1]` suffix from Cursor workspace storage.

---

## Primary archive (Glam Up pink system)

| File | Screen name | Verified Glam phase | Hybrid notes |
|------|-------------|---------------------|--------------|
| [01-app-opening.png](01-app-opening.png) | Home / app opening | Home v1 | Carousel + “Ready to Glam Up?” — map copy to Verified Glam; **do not** copy script logo |
| [02-face-analysis-home.png](02-face-analysis-home.png) | Home carousel — Facial Analysis | Home | White card, line-art face in circle, viewfinder brackets, pill “Start scan” |
| [03-colour-analysis-home.png](03-colour-analysis-home.png) | Home carousel — Color Analysis | Home | Same card pattern; color-wheel style illustration |
| *(missing)* | Home carousel — Glow Up Guide | Home | Not in upload set; infer from 02/03 card anatomy |
| [05-scans-empty.png](05-scans-empty.png) | Scans tab — empty state | Scans / history | Center illustration + “No Scans Yet” + pill CTA |
| [07-settings-sheet.png](07-settings-sheet.png) | Settings bottom sheet | More / settings | Pill rows: Share, invite, support, IG, privacy |
| [08-scan-face-camera.png](08-scan-face-camera.png) | Face scan / camera | Scan pipeline | Live camera + face frame UI |
| [09-gender.png](09-gender.png) | Onboarding — gender | Questionnaire | Four solid pill options (single-select) |
| [10-beauty-goals.png](10-beauty-goals.png) | Onboarding — beauty goals | Questionnaire | Multi-select: filled vs outline rows |
| [11-skin-type.png](11-skin-type.png) | Onboarding — skin type | Questionnaire | Selection list pattern |
| [12-skin-types.png](12-skin-types.png) | Onboarding — skin types (variant) | Questionnaire | Extended skin-type UI |
| [13-aesthetic-look-type.png](13-aesthetic-look-type.png) | Onboarding — aesthetic | Questionnaire | Photo-in-card carousel (“Soft Girl”) |
| [15-favorite-products.png](15-favorite-products.png) | Onboarding — favorite products | Questionnaire | Product preference step |
| [16-upload-or-take-pic.png](16-upload-or-take-pic.png) | Scan — photo source | Scan pipeline | Camera vs gallery choice |
| [17-upload-scan-rules.png](17-upload-scan-rules.png) | Scan — upload rules | Scan pipeline | Do’s/don’ts for photo quality |
| [18-setting-everything.png](18-setting-everything.png) | Account setup / processing | Post-onboarding | “Setting everything up” loader |
| [19-account-ready.png](19-account-ready.png) | Profile ready | Post-onboarding | Success + benefit cards → maps to `BMWelcomeScreen` |
| [20-allow-notifications.png](20-allow-notifications.png) | Push permission | Onboarding | Maps to `BMEnableNotificationScreen` |
| [21-leave-a-review.png](21-leave-a-review.png) | Store rating prompt | Onboarding (late) | Stars + thumbs illustration |
| [22-language.png](22-language.png) | Language picker | Settings / i18n | Flag + radio rows; **ignore** green ad banner |
| [23-paywall-dark.png](23-paywall-dark.png) | Paywall — dark comparison | Monetization | Feature matrix Free vs PRO; emerald accent |
| [24-paywall-promo-overlay.png](24-paywall-promo-overlay.png) | Paywall — promo overlay | Monetization | Gradient modal, countdown, 50% off |

### Gaps in numbered set

| Planned ID | Status |
|------------|--------|
| `04-glow-up-home.png` | Not in source upload — use 02/03 as card template |
| `06-select-a-scan.png` | Merged with `05-scans-empty.png` (same flow: empty + “Select a scan” CTA) |
| `14-pretty-goal.png` | Covered by `10-beauty-goals.png` (source: `Pretty_Goal`) |

---

## Alternate reference (teal “Beauty Scanner” onboarding)

Different accent (teal/green) — use for **processing screen** and optional onboarding illustration style, not primary Verified Glam colors.

| File | Screen name | Notes |
|------|-------------|-------|
| [alt-01-facial-trait-onboarding.png](alt-01-facial-trait-onboarding.png) | Facial trait intro | Flat illustration + teal START button |
| [alt-02-face-score-onboarding.png](alt-02-face-score-onboarding.png) | Golden ratio / face score intro | Teal outlined NEXT, score overlay on phone |

---

## Usage rules

1. **Legal:** Inspiration only; do not copy competitor name, logo, or exact layout pixel-for-pixel.
2. **Brand:** Implement with [DESIGN_SYSTEM_LOCKED.md](../../DESIGN_SYSTEM_LOCKED.md) tokens (`#872B3F`, `#C79A9A`, `#F6E3E3`), not competitor coral pink.
3. **Walkthrough:** Template `images/model_one|two|three.jpg` stays locked; these screenshots do not replace walkthrough photos.

*Archived: documentation phase — competitor design memory.*
