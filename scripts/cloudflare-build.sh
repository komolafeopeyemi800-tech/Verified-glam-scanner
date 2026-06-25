#!/usr/bin/env bash
# Cloudflare Pages build — installs Flutter, syncs marketing, builds web with dart-defines.
# Required env: SUPABASE_URL, SUPABASE_ANON_KEY
# Optional env: GOOGLE_WEB_CLIENT_ID

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Cloudflare dashboard multiline fields sometimes inject CR/LF/tabs into values.
sanitize_env() {
  printf '%s' "${1:-}" | tr -d '\r\n\t'
}

SUPABASE_URL="$(sanitize_env "${SUPABASE_URL:-}")"
SUPABASE_ANON_KEY="$(sanitize_env "${SUPABASE_ANON_KEY:-}")"
GOOGLE_WEB_CLIENT_ID="$(sanitize_env "${GOOGLE_WEB_CLIENT_ID:-}")"

if [[ -z "${SUPABASE_URL}" || -z "${SUPABASE_ANON_KEY}" ]]; then
  echo "ERROR: Set SUPABASE_URL and SUPABASE_ANON_KEY in Cloudflare Pages environment variables." >&2
  exit 1
fi

# Production Cloudflare builds always use live Supabase + real analysis.
VG_USE_SUPABASE="true"
VG_USE_MOCK_ANALYSIS="false"

echo "==> Sync marketing site (website/ -> web/marketing/)"
if [[ ! -d website ]]; then
  echo "ERROR: Missing website/ folder." >&2
  exit 1
fi
rm -rf web/marketing
cp -r website web/marketing
cat > web/marketing/js/config.js << 'EOF'
/**
 * Flutter web app (integrated) — Log in / Sign up stay on same origin.
 */
window.VG_APP_URL = "/login";
window.VG_REGISTER_URL = "/register";
window.VG_INTEGRATED_APP = true;
EOF
cat > web/marketing/_headers << 'EOF'
/marketing/*
  X-Frame-Options: SAMEORIGIN
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()

/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
EOF

echo "==> Install Flutter stable"
FLUTTER_DIR="${HOME}/flutter"
if [[ ! -d "${FLUTTER_DIR}/bin" ]]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi
export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter --version
flutter config --enable-web --no-analytics
flutter precache --web

echo "==> flutter pub get"
flutter pub get

echo "==> flutter build web"
BUILD_ARGS=(
  build web
  --release
  --no-wasm-dry-run
  --no-tree-shake-icons
  "--dart-define=SUPABASE_URL=${SUPABASE_URL}"
  "--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}"
  "--dart-define=VG_USE_SUPABASE=${VG_USE_SUPABASE}"
  "--dart-define=VG_USE_MOCK_ANALYSIS=${VG_USE_MOCK_ANALYSIS}"
)
if [[ -n "${GOOGLE_WEB_CLIENT_ID}" ]]; then
  BUILD_ARGS+=("--dart-define=GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID}")
fi
flutter "${BUILD_ARGS[@]}"

BOOTSTRAP="${ROOT}/build/web/flutter_bootstrap.js"
if [[ -f "${BOOTSTRAP}" ]]; then
  echo "==> Disable Flutter service worker (static hosting)"
  sed -i 's/serviceWorkerSettings: {[^}]*}/serviceWorkerSettings: null/g' "${BOOTSTRAP}" || \
    sed -i '' 's/serviceWorkerSettings: {[^}]*}/serviceWorkerSettings: null/g' "${BOOTSTRAP}" 2>/dev/null || true
fi

if [[ -f web/serve.json ]]; then
  cp -f web/serve.json build/web/serve.json
fi

if [[ -d web/marketing ]]; then
  rm -rf build/web/marketing
  cp -r web/marketing build/web/marketing
fi

# SPA deep links on Cloudflare Pages: serve index.html for unknown routes.
# Do not use web/_redirects (wrangler rejects /* and /app/* -> /index.html loops).
if [[ -f build/web/index.html ]]; then
  cp -f build/web/index.html build/web/404.html
fi

echo "==> Build complete: build/web/"
