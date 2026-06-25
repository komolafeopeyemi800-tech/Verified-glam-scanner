# Verified Glam — Web app + Cloudflare hosting

Operator runbook for the Flutter web app on **Cloudflare Pages**, with backend on **Supabase** (same project as Android).

## Architecture

| Layer | Host | URL |
|-------|------|-----|
| Flutter web UI | Cloudflare Pages | e.g. `verified-glam-scanner.pages.dev` or `app.verifiedglam.com` |
| Auth, DB, storage, Edge Functions | Supabase | `https://qmivgvctmxvpnbouqslj.supabase.co` |
| OpenAI | Supabase Edge Function secrets only | Never in Cloudflare env vars |

```text
Browser → Cloudflare (static build/web) → Supabase Auth / Storage / analyze-scan → OpenAI
Android → Supabase (same project)
```

Flutter bakes `SUPABASE_URL` and keys into `main.dart.js` at **build time** via `--dart-define` (see [`lib/services/supabase/vg_supabase_config.dart`](../lib/services/supabase/vg_supabase_config.dart)).

## Cloudflare Pages — environment variables

**Dashboard → Workers & Pages → your project → Settings → Environment variables**

Set for **Production** (and **Preview** if you use PR previews):

| Variable | Required | Example / notes |
|----------|----------|-----------------|
| `SUPABASE_URL` | Yes | `https://qmivgvctmxvpnbouqslj.supabase.co` |
| `SUPABASE_ANON_KEY` | Yes | Publishable/anon key from Supabase → Project Settings → API |
| `GOOGLE_WEB_CLIENT_ID` | If using Google sign-in | `….apps.googleusercontent.com` |

`VG_USE_SUPABASE` and `VG_USE_MOCK_ANALYSIS` are **hardcoded** in [`scripts/cloudflare-build.sh`](../scripts/cloudflare-build.sh) (`true` / `false`) — you do not need to set them in Cloudflare. If you previously added them, remove any line breaks in other values (paste as a single line).

**Never** put these in Cloudflare:

| Secret | Where |
|--------|--------|
| `OPENAI_API_KEY` | Supabase → Edge Functions → Secrets |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase only |
| `SUPABASE_ACCESS_TOKEN` | Local `.env` / CLI only |
| `TEST_USER_*` | Local `.env` only (E2E script) |
| `FCM_SERVICE_ACCOUNT_JSON` | Supabase secrets (Android push) |

## Cloudflare Pages — build settings (Git-connected)

Cloudflare’s build image does **not** include Flutter. The repo provides [`scripts/cloudflare-build.sh`](../scripts/cloudflare-build.sh).

| Setting | Value |
|---------|--------|
| **Production branch** | `main` |
| **Build command** | `bash scripts/cloudflare-build.sh` |
| **Build output directory** | `build/web` |
| **Root directory** | `/` (repo root) |

**Connect Git:** Workers & Pages → Create → Pages → Connect to Git → `komolafeopeyemi800-tech/Verified-glam-scanner`.

SPA deep links: [`web/_redirects`](../web/_redirects) (`/* /index.html 200`) is copied into the Flutter web build.

## Alternative: GitHub Actions deploy

[`docs/deploy-web-workflow.yml.example`](../docs/deploy-web-workflow.yml.example) is an optional workflow (copy to `.github/workflows/deploy-web.yml`). It uses **manual `workflow_dispatch` only** to avoid double-deploy when Cloudflare builds from Git.

If you use GitHub Actions instead of Cloudflare build, set **GitHub Secrets**: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`, `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` — and leave Cloudflare Pages build command empty or use “Direct Upload” from the Action.

**Note:** Pushing workflow files requires a GitHub token with the `workflow` scope. The example file lives under `docs/` so the initial repo push works without that scope.

## Local development

1. Copy `.env.example` → `.env` with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`.
2. Supabase → Authentication → URL configuration: Site URL `http://localhost:8080`, redirect `http://localhost:8080/**`.
3. Run:

```powershell
.\scripts\run-web-dev.ps1
```

4. Production build locally:

```powershell
.\scripts\build-web.ps1
```

Output: `build/web/`

**Passkeys SDK:** [`web/js/passkeys-bundle.js`](../web/js/passkeys-bundle.js) must load from [`web/index.html`](../web/index.html) before `flutter_bootstrap.js`.

## Supabase — web auth (dashboard)

**Authentication → URL configuration** (use your live Pages URL after first deploy):

| Setting | Value |
|---------|--------|
| Site URL | `https://<your-pages-domain>` |
| Redirect URLs | `https://<your-pages-domain>/**`, `http://localhost:**` |

**Google provider**

1. `GOOGLE_WEB_CLIENT_ID` in Cloudflare env vars (and local `.env`).
2. Google Cloud Console → OAuth client:
   - Authorized JavaScript origins: your Pages URL, `http://localhost`
   - Authorized redirect URI: `https://qmivgvctmxvpnbouqslj.supabase.co/auth/v1/callback`

PKCE is enabled in [`lib/services/supabase/vg_supabase_init.dart`](../lib/services/supabase/vg_supabase_init.dart).

## What auto-deploys on push

| Change | Auto-deploy? |
|--------|----------------|
| Push to `main` (Cloudflare Git integration) | Yes — Cloudflare runs `cloudflare-build.sh` |
| `supabase/migrations/` | No — `supabase db push` |
| Edge Functions | No — `.\scripts\deploy-functions.ps1` |
| Supabase secrets | No — Dashboard |

## Custom domain (optional)

After first deploy: Pages → **Custom domains** → e.g. `app.verifiedglam.com`. Update Supabase Site URL and Google OAuth origins to match.

## Verification checklist

1. [ ] Homepage loads at Pages URL
2. [ ] `/login` — sign up / log in
3. [ ] `/app/face-beauty-analysis` — upload → Analyze (signed in)
4. [ ] Network tab: only `*.supabase.co`, not `api.openai.com`
5. [ ] Mobile width (~390px): drawer nav, stacked workspace

## Troubleshooting

| Issue | Check |
|-------|--------|
| Build fails: Flutter not found | Build command must be `bash scripts/cloudflare-build.sh` |
| `SUPABASE_URL` missing in app | Cloudflare env vars set; rebuild |
| Startup crash / `PasskeyAuthenticator.init` | `web/js/passkeys-bundle.js` in repo |
| 404 on refresh `/app/...` | `web/_redirects` present in build output |
| Google sign-in fails | Supabase redirect URLs + `GOOGLE_WEB_CLIENT_ID` |
| 401 on analyze-scan | User signed in; Edge Function deployed |

See also: [SUPABASE_SETUP.md](SUPABASE_SETUP.md), [website/README.md](../website/README.md).
