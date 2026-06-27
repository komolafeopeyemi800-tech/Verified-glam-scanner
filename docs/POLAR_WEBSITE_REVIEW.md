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
