# Verified Glam — Marketing site

Static marketing landing page. Lives in this monorepo alongside the Flutter app; the app does not build or import these files.

## URL plan (when you go live)

| URL | Role |
|-----|------|
| Your main domain (e.g. marketing / legacy site) | Landing, SEO, Play Store links — **not** the Flutter app |
| `https://app.verifiedglam.com` | Flutter web product (login, dashboard, scans) — **subdomain only, after you finish testing** |

**Until the app is deployed:** all “Log in” / “Sign up” links on this site point to **`http://localhost:8080`** (see `js/config.js`). Do not point marketing at `app.verifiedglam.com` until Cloudflare is configured.

## Local testing (marketing + web app)

Use **two terminals** from the repo root:

**Terminal 1 — Flutter web app** (login, signup, dashboard, scans):

```powershell
.\scripts\run-web-dev.ps1
```

Opens Chrome at **http://localhost:8080** with Supabase from your `.env`.

**Terminal 2 — Marketing site** (optional, to test Log in links):

```powershell
.\scripts\serve-website.ps1
```

Opens **http://localhost:3000**. Click **Log in** → goes to the Flutter app on port 8080.

You can also open the app directly at http://localhost:8080 without the marketing site.

### Supabase for local web

In Supabase Dashboard → **Authentication → URL configuration**:

- Site URL: `http://localhost:8080`
- Redirect URLs: `http://localhost:8080/**`, `http://localhost:**`

See [SUPABASE_SETUP.md](../docs/SUPABASE_SETUP.md).

### Switch to production app URL

When `app.verifiedglam.com` is live on Cloudflare, edit [`js/config.js`](js/config.js):

```javascript
// window.VG_APP_URL = "http://localhost:8080";
window.VG_APP_URL = "https://app.verifiedglam.com";
```

Redeploy the marketing Pages project. Update Supabase Site URL to `https://app.verifiedglam.com`.

## Deploy to Cloudflare Pages

1. Push this repository to GitHub (or connect your existing remote).
2. In [Cloudflare Dashboard](https://dash.cloudflare.com/) → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
3. Select this repository.
4. Configure build settings:

| Setting | Value |
|---------|--------|
| **Root directory** | `website` |
| **Build command** | *(leave empty)* |
| **Build output directory** | `/` |

5. Deploy. Your site will be available at `https://<project-name>.pages.dev`.
6. Optional: add a custom domain under **Pages → your project → Custom domains**.

Flutter web deploy (subdomain `app.verifiedglam.com`) is separate — [WEB_APP_CLOUDFLARE_PLAN.md](../docs/WEB_APP_CLOUDFLARE_PLAN.md).

## Local preview (marketing only)

```powershell
.\scripts\serve-website.ps1
```

Or: `npx serve website`

## CLI deploy (optional)

From the repo root:

```bash
npx wrangler pages deploy website --project-name=verified-glam
```

Requires [Wrangler](https://developers.cloudflare.com/workers/wrangler/) and Cloudflare authentication.

## Google Play link

The Play Store listing URL used across the site:

```
https://play.google.com/store/apps/details?id=com.verifiedglam.beauty_scanner
```

Replace or update this URL in `index.html` if the package ID or listing changes.

## Support email

`support@verifiedglam.com` (see `lib/utils/vg_constants.dart` in the Flutter app — update app constant when email is live).

## Files

```
website/
  index.html          Landing page
  privacy.html        Privacy Policy
  terms.html          Terms of Use
  css/styles.css      Verified Glam brand tokens + layout
  js/config.js        App URL for Log in links (localhost vs production)
  js/main.js          Mobile nav + FAQ + app link wiring
  assets/             Logo, favicon, walkthrough images, Play badge
  robots.txt
  sitemap.xml
  _headers            Cloudflare security headers
```

## SEO note

`sitemap.xml` and `robots.txt` reference `https://verifiedglam.com/`. After you attach a custom domain on Cloudflare Pages, update those URLs if your live domain differs from `*.pages.dev`.
