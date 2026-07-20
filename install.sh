#!/bin/bash
# Launch Codex with a loopback-only DevTools port, then keep the skin injected.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
. "$ROOT/runtime.sh"
STATE_DIR="$HOME/Library/Application Support/CodexQQSkin"
STATE_FILE="$STATE_DIR/simple-state"
PORT="${CODEX_QQ_SKIN_PORT:-9341}"

case "$PORT" in ''|*[!0-9]*) echo "Invalid port: $PORT" >&2; exit 1 ;; esac
[ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || { echo "Port must be 1024–65535." >&2; exit 1; }

APP="$(find_codex_app)" || { echo "Could not find the official Codex app." >&2; exit 1; }
NODE="$(resolve_codex_node)" || { echo "Codex's bundled Node.js 20+ runtime is required." >&2; exit 1; }
"$NODE" "$ROOT/injector.js" --check-payload >/dev/null

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"
if [ -f "$STATE_FILE" ]; then
  old_pid="$(sed -n 's/^pid=//p' "$STATE_FILE")"
  old_port="$(sed -n 's/^port=//p' "$STATE_FILE")"
  old_node="$(sed -n 's/^node=//p' "$STATE_FILE")"
  old_injector="$(sed -n 's/^injector=//p' "$STATE_FILE")"
  old_started="$(sed -n 's/^started=//p' "$STATE_FILE")"
  if recorded_watcher_matches "$old_pid" "$old_started" "$old_node" "$old_injector" "$old_port"; then
    kill -TERM "$old_pid" 2>/dev/null || true
  else
    echo "Previous watcher state could not be verified; leaving it untouched." >&2
  fi
fi

open -na "$APP" --args --remote-debugging-address=127.0.0.1 --remote-debugging-port="$PORT"
"$NODE" "$ROOT/injector.js" --watch --port "$PORT" --timeout-ms 120000 >"$STATE_DIR/injector.log" 2>"$STATE_DIR/injector-error.log" &
PID="$!"
STARTED="$(process_started_at "$PID")"
[ -n "$STARTED" ] || { kill -TERM "$PID" 2>/dev/null || true; echo "Could not record watcher identity." >&2; exit 1; }
printf 'pid=%s\nport=%s\nnode=%s\ninjector=%s\nstarted=%s\n' \
  "$PID" "$PORT" "$NODE" "$ROOT/injector.js" "$STARTED" > "$STATE_FILE"
chmod 600 "$STATE_FILE"
if ! /bin/bash "$ROOT/verify.sh" --timeout-ms 30000; then
  kill -TERM "$PID" 2>/dev/null || true
  rm -f "$STATE_FILE"
  echo "Codex QQ Skin could not be verified; see $STATE_DIR/injector-error.log" >&2
  exit 1
fi
echo "Codex QQ Skin is active on 127.0.0.1:$PORT (watcher $PID)."
