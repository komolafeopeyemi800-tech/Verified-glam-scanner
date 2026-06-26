#!/usr/bin/env bash
# Overlay static marketing HTML on build/web after Flutter build.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/web"

if [[ ! -d "$BUILD" ]]; then
  echo "ERROR: Missing build/web" >&2
  exit 1
fi

echo "==> Generate static HTML pages"
if command -v dart >/dev/null 2>&1; then
  (cd "$ROOT" && dart run tool/generate_marketing_html.dart)
elif [[ -x "${HOME}/flutter/bin/dart" ]]; then
  (cd "$ROOT" && "${HOME}/flutter/bin/dart" run tool/generate_marketing_html.dart)
elif command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "${ROOT}/scripts/sync-static-site.ps1"
  exit 0
else
  echo "ERROR: dart not found for generate_marketing_html.dart" >&2
  exit 1
fi

mkdir -p "$BUILD/_flutter"
cp -f "$BUILD/index.html" "$BUILD/_flutter/index.html"
cp -f "$BUILD/_flutter/index.html" "$BUILD/404.html"

echo "==> Copy marketing assets"
if [[ -d "$ROOT/images/vg/marketing" ]]; then
  mkdir -p "$BUILD/assets"
  cp -R "$ROOT/images/vg/marketing/." "$BUILD/assets/"
fi
rm -rf "$BUILD/css" "$BUILD/js"
cp -R "$ROOT/website/css" "$BUILD/css"
cp -R "$ROOT/website/js" "$BUILD/js"

SUPABASE_URL="$(printf '%s' "${SUPABASE_URL:-}" | tr -d '\r\n\t')"
SUPABASE_ANON_KEY="$(printf '%s' "${SUPABASE_ANON_KEY:-}" | tr -d '\r\n\t')"
GOOGLE_WEB_CLIENT_ID="$(printf '%s' "${GOOGLE_WEB_CLIENT_ID:-}" | tr -d '\r\n\t')"

if [[ -f "$BUILD/js/auth-config.js" ]]; then
  sed -i "s|__SUPABASE_URL__|${SUPABASE_URL}|g" "$BUILD/js/auth-config.js" 2>/dev/null || \
    sed -i '' "s|__SUPABASE_URL__|${SUPABASE_URL}|g" "$BUILD/js/auth-config.js"
  sed -i "s|__SUPABASE_ANON_KEY__|${SUPABASE_ANON_KEY}|g" "$BUILD/js/auth-config.js" 2>/dev/null || \
    sed -i '' "s|__SUPABASE_ANON_KEY__|${SUPABASE_ANON_KEY}|g" "$BUILD/js/auth-config.js"
  sed -i "s|__GOOGLE_WEB_CLIENT_ID__|${GOOGLE_WEB_CLIENT_ID}|g" "$BUILD/js/auth-config.js" 2>/dev/null || \
    sed -i '' "s|__GOOGLE_WEB_CLIENT_ID__|${GOOGLE_WEB_CLIENT_ID}|g" "$BUILD/js/auth-config.js"
fi

cp -f "$ROOT/website/index.html" "$BUILD/index.html"

if [[ -d "$ROOT/website/generated" ]]; then
  for dir in "$ROOT/website/generated"/*/; do
    name="$(basename "$dir")"
    rm -rf "$BUILD/$name"
    cp -R "$dir" "$BUILD/$name"
  done
fi

for f in sitemap.xml robots.txt llms.txt _redirects; do
  if [[ -f "$ROOT/website/$f" ]]; then
    cp -f "$ROOT/website/$f" "$BUILD/$f"
  fi
done

rm -rf "$BUILD/_static" "$BUILD/marketing"
echo "Static overlay complete."
