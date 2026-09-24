#!/usr/bin/env bash
# Smoke test: start the real stack with dummy config and check that it serves.
#
# It builds caddy, pulls the pinned sb-ctrl and sb-ctrl-ui images, and runs
# them under the separate project name "sb-stack-smoke". A deployment in the
# same checkout is not touched. No seedbox, no real secrets, no ACME.
#
# Usage: tests/smoke.sh    (needs Docker with Compose 2.24 or later, and curl)
# SMOKE_PORT sets the local HTTPS port, default 8443.
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT=sb-stack-smoke
SMOKE_PORT="${SMOKE_PORT:-8443}"
SMOKE_DIR="$(mktemp -d)"
BASE="https://localhost:${SMOKE_PORT}"
TOKEN="smoke-$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
export SMOKE_DIR SMOKE_PORT

compose() {
  docker compose -p "$PROJECT" --env-file "$SMOKE_DIR/.env" \
    -f docker-compose.yml -f tests/docker-compose.smoke.yml "$@"
}

failed=0
cleanup() {
  if [ "$failed" -ne 0 ]; then
    echo "--- container logs ---"
    compose logs --no-color || true
  fi
  compose down -v --remove-orphans >/dev/null 2>&1 || true
  rm -rf "$SMOKE_DIR" 2>/dev/null || true
}
trap cleanup EXIT

fail() {
  failed=1
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "ok: $*"
}

# Throwaway env. MEDIA_ROOT is an empty dir; nothing is transferred.
mkdir -p "$SMOKE_DIR/media/.staging"
cat > "$SMOKE_DIR/.env" <<EOF
DOMAIN=localhost
ACME_EMAIL=smoke@example.com
IONOS_API_KEY=smoke.dummy
MEDIA_ROOT=$SMOKE_DIR/media
EOF

# Dummy sb-ctrl config. The .invalid hosts never resolve, which is fine:
# the checked endpoints do not call the seedbox, TMDb or Plex.
cat > "$SMOKE_DIR/config.toml" <<EOF
staging_root = "/data/.staging"

[rtorrent]
url  = "https://seedbox.invalid/xmlrpc"
user = "smoke"
pass = "smoke"

[sftp]
host = "seedbox.invalid"
base = "files"

[tmdb]
key = "smoke"

[roots]
movies         = "/data/media/movies"
cartoons       = "/data/media/cartoons"
series         = "/data/media/series"
cartoon_series = "/data/media/cartoon-series"

[auth]
user          = "smoke"
password_hash = "scrypt\$smoke\$smoke"
secret        = "smoke-secret"

[api]
host  = "0.0.0.0"
port  = 8765
token = "$TOKEN"
EOF

# The real Caddyfile with the IONOS DNS-01 block replaced by Caddy's internal
# CA. Routing stays as deployed.
awk '
  /^\ttls \{$/ { print "\ttls internal"; skip = 1; next }
  skip && /^\t\}$/ { skip = 0; next }
  !skip { print }
' Caddyfile > "$SMOKE_DIR/Caddyfile"
grep -q 'tls internal' "$SMOKE_DIR/Caddyfile" || fail "tls block not found in Caddyfile"
grep -q 'dns ionos' "$SMOKE_DIR/Caddyfile" && fail "tls block not replaced"

compose up -d --build --wait --wait-timeout 180 || fail "stack did not start"
pass "stack started"

# The deployed Caddyfile, unchanged, must parse with the built caddy image.
docker run --rm --env-file "$SMOKE_DIR/.env" \
  -v "$PWD/Caddyfile:/etc/caddy/Caddyfile:ro" "$PROJECT-caddy" \
  caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null 2>&1 \
  || fail "Caddyfile does not validate"
pass "Caddyfile validates with the IONOS plugin"

# GET <path> [curl args...]: prints the body, then the status code on the last line.
get() {
  local path="$1"
  shift
  curl -sS -k --max-time 10 --resolve "localhost:${SMOKE_PORT}:127.0.0.1" \
    -w '\n%{http_code}' "$@" "${BASE}${path}"
}

# Wait until caddy has its certificate and sb-ctrl answers.
for _ in $(seq 1 30); do
  if out="$(get /api/health 2>/dev/null)" && [ "${out##*$'\n'}" = 200 ]; then
    break
  fi
  sleep 2
done

check() {
  local name="$1" path="$2" want_code="$3" want_body="$4"
  shift 4
  local out code body
  out="$(get "$path" "$@")" || fail "$name: request failed"
  code="${out##*$'\n'}"
  body="${out%$'\n'*}"
  [ "$code" = "$want_code" ] || fail "$name: HTTP $code, want $want_code. Body: $body"
  case "$body" in
    *"$want_body"*) ;;
    *) fail "$name: body lacks '$want_body'. Body: $body" ;;
  esac
  pass "$name"
}

check "UI serves the index page" / 200 '<title>sb-ctrl</title>'
check "UI serves config.js with the /api base" /config.js 200 'window.SB_API_BASE="/api"'
check "API health answers ok" /api/health 200 '"ok":true'
check "API reports login required" /api/me 200 '"login_required":true'
check "API rejects a request without a token" /api/config 401 'unauthorized'
check "API rejects a wrong token" /api/config 401 'unauthorized' -H "Authorization: Bearer wrong"
check "API accepts the token and reads the config" /api/config 200 'seedbox.invalid' \
  -H "Authorization: Bearer $TOKEN"

out="$(get /api/config -H "Authorization: Bearer $TOKEN")"
case "$out" in
  *"$TOKEN"*) fail "API config leaks the token" ;;
esac
pass "API config redacts the token"

echo "smoke test passed"
