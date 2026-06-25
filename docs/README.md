# Verified Glam — Project documentation

This folder is the **single source of truth** for building Verified Glam on top of the Beauty Master Flutter template.

## Start here

| Document | Read when |
|----------|-----------|
| [DESIGN_SYSTEM_LOCKED.md](DESIGN_SYSTEM_LOCKED.md) | Any UI work — colors, walkthrough, layout rules |
| [HYBRID_DESIGN_RULES.md](HYBRID_DESIGN_RULES.md) | Keep template shell vs adopt competitor UI patterns |
| [DESIGN_SYSTEM_COMPETITOR_REFERENCE.md](DESIGN_SYSTEM_COMPETITOR_REFERENCE.md) | Competitor design system (buttons, cards, icons, screens) |
| [RESULT_UI_COMPETITOR_REFERENCE.md](RESULT_UI_COMPETITOR_REFERENCE.md) | Result screens: photo hero + face overlays (Phase 6) |
| [reference/competitor-screenshots/README.md](reference/competitor-screenshots/README.md) | Archived competitor screenshots — onboarding, home, scan |
| [reference/competitor-results/README.md](reference/competitor-results/README.md) | Archived competitor result/output screenshots (29) |
| [VERIFIED_GLAM_PRODUCT.md](VERIFIED_GLAM_PRODUCT.md) | What the app does, features, monetization |
| [TEMPLATE_TO_VERIFIED_GLAM_MAP.md](TEMPLATE_TO_VERIFIED_GLAM_MAP.md) | Which existing screen maps to which product flow |
| [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) | Phased implementation plan |
| [SUPABASE_SETUP.md](SUPABASE_SETUP.md) | Supabase project, auth, Edge Function, Flutter dart-defines |
| [WEB_APP_CLOUDFLARE_PLAN.md](WEB_APP_CLOUDFLARE_PLAN.md) | Flutter web at `app.verifiedglam.com`, GitHub Actions → Cloudflare Pages |
| [CELEBRITY_IMAGE_SETUP.md](CELEBRITY_IMAGE_SETUP.md) | TMDB + portrait fallback for Celebrity Look Alike match cards |
| [source/VERIFIED_GLAM_FULL_SPEC.md](source/VERIFIED_GLAM_FULL_SPEC.md) | Complete original product specification |
| [design-system/MASTER.md](design-system/MASTER.md) | Pointer to locked design system |

## Monorepo layout

| Path | Purpose |
|------|---------|
| `lib/`, `android/`, `web/` | Flutter app (Android + web product at `app.verifiedglam.com`) |
| [`website/`](../website/) | Optional static marketing — [Cloudflare Pages](../website/README.md) (root: `website`, no build) |

## Rules

- **Default:** Change content and logic; new feature screens use **hybrid** rules (template colors + competitor component patterns).
- **Walkthrough:** Keep `images/model_one.jpg`, `model_two.jpg`, `model_three.jpg`.
- **Competitor reference:** Inspiration only — do not copy competitor brand or coral-pink palette literally (see `HYBRID_DESIGN_RULES.md`).
- **Stack:** Flutter + Supabase + OpenAI via Edge Functions (not React Native from the original spec).

Agents: see `.cursor/rules/verified-glam.mdc`.
