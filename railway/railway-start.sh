#!/usr/bin/env bash
# Railway wrapper for Octop:
#  1. waits (up to 180 s) for Postgres, so first-boot `octop init` does not race the database;
#  2. makes sure the generated OCTOP_DEFAULT_PASSWORD passes Octop's policy (>= 8 chars, letters AND digits),
#     so the admin account is always created and the setup wizard is never left open;
#  3. hands over to the upstream docker-entrypoint.sh (octop init on first boot, then `octop run`).
set -euo pipefail
export HOME="${HOME:-/data}"
# Listen where Railway routes and health-checks: its PORT wins, then OCTOP_PORT, then 8088.
export OCTOP_PORT="${PORT:-${OCTOP_PORT:-8088}}"
mkdir -p "${OCTOP_HOME:-$HOME/.octop}"

if [ -n "${OCTOP_DATABASE_URL:-}" ]; then
  case "$OCTOP_DATABASE_URL" in
    postgres://*|postgresql://*) export OCTOP_DATABASE_DRIVER="${OCTOP_DATABASE_DRIVER:-postgresql}" ;;
  esac
  python - <<'PY'
import os, socket, time, urllib.parse
u = urllib.parse.urlparse(os.environ["OCTOP_DATABASE_URL"])
host, port = u.hostname, u.port or 5432
end = time.time() + 180
while True:
    try:
        socket.create_connection((host, port), timeout=3).close()
        print(f"[railway] Postgres reachable at {host}:{port}", flush=True)
        break
    except OSError:
        if time.time() > end:
            print("[railway] Postgres still unreachable after 180 s, starting anyway", flush=True)
            break
        print("[railway] waiting for Postgres...", flush=True)
        time.sleep(3)
PY
  # Give Postgres a moment to finish accepting logins after the port opens.
  sleep 3
fi

pw="${OCTOP_DEFAULT_PASSWORD:-}"
if [ -n "$pw" ]; then
  fixed="$pw"
  printf '%s' "$fixed" | grep -q '[A-Za-z]' || fixed="${fixed}a"
  printf '%s' "$fixed" | grep -q '[0-9]' || fixed="${fixed}7"
  while [ "${#fixed}" -lt 8 ]; do fixed="${fixed}x7"; done
  if [ "$fixed" != "$pw" ]; then
    echo "[railway] OCTOP_DEFAULT_PASSWORD did not meet Octop's policy; the admin password is it with '${fixed#"$pw"}' appended."
    export OCTOP_DEFAULT_PASSWORD="$fixed"
  fi
fi

echo "[railway] Octop listening on port ${OCTOP_PORT}"
echo "[railway] Octop admin user: ${OCTOP_ADMIN_USERNAME:-admin} (password = OCTOP_DEFAULT_PASSWORD variable, used on first boot only)"
exec /usr/local/bin/docker-entrypoint.sh "$@"
