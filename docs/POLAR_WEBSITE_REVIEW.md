# Polar.sh website review — crawl readiness

Polar and similar reviewers crawl **https://scanner.verifiedglam.com** to verify your business, pricing, privacy, and terms pages.

## What was broken (June 2026)

Production served **only the Flutter app shell** at `/`. Static marketing pages (`/pricing`, `/privacy`, `/terms`, `/about`, tool landings) returned **404** because the Cloudflare build did not overlay `website/generated/` onto `build/web/`.

Review bots cannot execute Flutter — they need **plain HTML** with visible text.

## Required deploy pipeline

Cloudflare **must** use:

| Setting | Value |
|---------|--------|
| Root directory | *(repo root)* |
| Build command | `bash scripts/cloudflare-build.sh` |
| Build output | `build/web` |

Do **not** deploy `website/` alone or raw `flutter build web` without `sync-static-site`.

## Verify before appeal

```powershell
.\scripts\deploy-cloudflare.ps1
# optional live deploy:
.\scripts\deploy-cloudflare.ps1 -Deploy
```

Or on Cloudflare’s Linux builder, `cloudflare-build.sh` fails if marketing pages are missing.

## Pages reviewers should access

| URL | Purpose |
|-----|---------|
| https://scanner.verifiedglam.com/ | Product home |
| https://scanner.verifiedglam.com/pricing | Plans + Polar checkout |
| https://scanner.verifiedglam.com/privacy | Privacy policy |
| https://scanner.verifiedglam.com/terms | Terms of service |
| https://scanner.verifiedglam.com/about | Company / product |
| https://scanner.verifiedglam.com/login | Account sign-in |
| https://scanner.verifiedglam.com/register | Account sign-up |

Sitemap: https://scanner.verifiedglam.com/sitemap.xml  
LLM index: https://scanner.verifiedglam.com/llms.txt

## After push

1. Trigger a Cloudflare Pages / Workers deploy from `main`.
2. Confirm `/pricing` returns **200** with HTML (not 404).
3. Re-submit Polar appeal with these URLs.

## Polar payment appeal (18+ eligibility)

If Polar denies payment access for “users under 18”, our public pages previously said “13 and older”. That followed app-store age-rating wording, not our billing audience. **Pro subscriptions require 18+** — Terms and Privacy now state this explicitly.

Paste this in Polar’s appeal form:

---

**Subject:** Appeal — Verified Glam Scanner is an 18+ adult product

Hello Polar team,

Our organization was flagged as targeting users under 18. That does not reflect our product or billing policy.

**Verified Glam Scanner** (https://scanner.verifiedglam.com) is an AI beauty analysis service for **adults aged 18 and older**. Users must be 18+ to create an account or purchase a Pro subscription. The service is not marketed to minors.

We previously included “13 and older” language in our FAQ following general mobile app age-rating conventions. That was misleading for payment compliance. We have updated all public pages:

- Terms: https://scanner.verifiedglam.com/terms (Section 1: Eligibility — 18+)
- Privacy: https://scanner.verifiedglam.com/privacy (Section 8: not directed at children or teens)
- Pricing: https://scanner.verifiedglam.com/pricing
- About: https://scanner.verifiedglam.com/about

**Product:** Selfie-based AI beauty analysis (entertainment/wellness, not medical advice). **Billing:** Credit-based Pro plans via Polar. **Platforms:** Web + Android, synced through Supabase accounts.

We do not sell to or target minors. Please re-review our organization with the updated policies.

Thank you,  
[Your name]  
Verified Glam — support@verifiedglam.com

---
