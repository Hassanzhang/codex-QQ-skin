#!/bin/bash
# Stop this skin's watcher and remove its injected renderer elements when possible.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
. "$ROOT/runtime.sh"
STATE_DIR="$HOME/Library/Application Support/CodexQQSkin"
STATE_FILE="$STATE_DIR/simple-state"

if [ ! -f "$STATE_FILE" ]; then
  echo "No simple QQ Skin session is recorded."
  exit 0
fi

PID="$(sed -n 's/^pid=//p' "$STATE_FILE")"
PORT="$(sed -n 's/^port=//p' "$STATE_FILE")"
NODE="$(sed -n 's/^node=//p' "$STATE_FILE")"
INJECTOR="$(sed -n 's/^injector=//p' "$STATE_FILE")"
STARTED="$(sed -n 's/^started=//p' "$STATE_FILE")"
case "$PORT" in ''|*[!0-9]*) PORT="" ;; esac

if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
  if recorded_watcher_matches "$PID" "$STARTED" "$NODE" "$INJECTOR" "$PORT"; then
    kill -TERM "$PID" 2>/dev/null || true
  else
    echo "Recorded watcher identity did not match; it was not stopped." >&2
  fi
fi
if [ -n "$PORT" ] && [ -x "$NODE" ]; then
  "$NODE" "$ROOT/injector.js" --remove --port "$PORT" --timeout-ms 5000 >/dev/null \
    || echo "Live renderer cleanup could not be confirmed; restart Codex to finish restoring." >&2
fi
rm -f "$STATE_FILE"
echo "Codex QQ Skin watcher stopped and renderer cleanup requested."
