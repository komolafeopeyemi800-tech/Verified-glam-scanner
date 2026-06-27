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
if grep -q 'flutter_bootstrap.js' "$BUILD/index.html" 2>/dev/null; then
  cp -f "$BUILD/index.html" "$BUILD/_flutter/index.html"
elif [[ ! -f "$BUILD/_flutter/index.html" ]] || ! grep -q 'flutter_bootstrap.js' "$BUILD/_flutter/index.html"; then
  if [[ -f "$ROOT/web/index.html" ]]; then
    sed 's/\$FLUTTER_BASE_HREF/\//g' "$ROOT/web/index.html" > "$BUILD/_flutter/index.html"
  fi
fi
if [[ -f "$BUILD/_flutter/index.html" ]] && grep -q 'flutter_bootstrap.js' "$BUILD/_flutter/index.html"; then
  cp -f "$BUILD/_flutter/index.html" "$BUILD/404.html"
fi

echo "==> Copy marketing assets"
if [[ -d "$ROOT/images/vg/marketing" ]]; then
  mkdir -p "$BUILD/assets"
  cp -R "$ROOT/images/vg/marketing/." "$BUILD/assets/"
fi
rm -rf "$BUILD/css"
cp -R "$ROOT/website/css" "$BUILD/css"

# Overlay marketing JS; keep Flutter shell scripts (passkeys-bundle.js for Supabase).
mkdir -p "$BUILD/js"
cp -R "$ROOT/website/js/." "$BUILD/js/"
if [[ -f "$ROOT/web/js/passkeys-bundle.js" ]]; then
  cp -f "$ROOT/web/js/passkeys-bundle.js" "$BUILD/js/passkeys-bundle.js"
else
  echo "WARNING: Missing web/js/passkeys-bundle.js — /app/* will crash on Supabase init" >&2
fi

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

cp -f "$ROOT/website/generated/home/index.html" "$BUILD/index.html"

if [[ -d "$ROOT/website/generated" ]]; then
  for dir in "$ROOT/website/generated"/*/; do
    name="$(basename "$dir")"
    if [[ "$name" == "home" ]]; then
      continue
    fi
    rm -rf "$BUILD/$name"
    cp -R "$dir" "$BUILD/$name"
  done
fi

for f in sitemap.xml robots.txt llms.txt _redirects _headers; do
  if [[ -f "$ROOT/website/$f" ]]; then
    cp -f "$ROOT/website/$f" "$BUILD/$f"
  fi
done

if [[ -f "$ROOT/web/serve.json" ]]; then
  cp -f "$ROOT/web/serve.json" "$BUILD/serve.json"
fi

rm -rf "$BUILD/_static" "$BUILD/marketing"

if [[ -f "$BUILD/_flutter/index.html" ]] && grep -q 'flutter_bootstrap.js' "$BUILD/_flutter/index.html"; then
  cp -f "$BUILD/_flutter/index.html" "$BUILD/404.html"
fi

echo "Static overlay complete."
