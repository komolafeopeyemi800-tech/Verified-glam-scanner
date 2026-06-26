#!/usr/bin/env bash
# Cloudflare Pages build — installs Flutter, builds web app shell, overlays static marketing HTML.
# Required env: SUPABASE_URL, SUPABASE_ANON_KEY
# Optional env: GOOGLE_WEB_CLIENT_ID

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

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

VG_USE_SUPABASE="true"
VG_USE_MOCK_ANALYSIS="false"

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

echo "==> flutter build web (app-only entry)"
BUILD_ARGS=(
  build web
  --release
  --no-wasm-dry-run
  -t lib/main_web.dart
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

echo "==> Overlay static marketing site"
bash "${ROOT}/scripts/sync-static-site.sh"

echo "==> Verify build output"
for required in build/web/index.html build/web/flutter_bootstrap.js build/web/main.dart.js build/web/login/index.html; do
  if [[ ! -f "${required}" ]]; then
    echo "ERROR: Missing ${required} — build incomplete." >&2
    exit 1
  fi
done
MAIN_SIZE="$(wc -c < build/web/main.dart.js | tr -d ' ')"
echo "    main.dart.js size: ${MAIN_SIZE} bytes"
if [[ "${MAIN_SIZE}" -lt 100000 ]]; then
  echo "ERROR: main.dart.js looks too small — build may have failed silently." >&2
  exit 1
fi

echo "==> Build complete: build/web/"
