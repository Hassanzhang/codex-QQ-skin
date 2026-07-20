#!/bin/bash
# Confirm that a recorded skin session is live and injected into Codex.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
STATE_FILE="$HOME/Library/Application Support/CodexQQSkin/simple-state"
TIMEOUT_MS=12000

while [ "$#" -gt 0 ]; do
  case "$1" in
    --timeout-ms) TIMEOUT_MS="${2:-}"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done
case "$TIMEOUT_MS" in ''|*[!0-9]*) echo "Invalid timeout." >&2; exit 1 ;; esac
[ -f "$STATE_FILE" ] || { echo "No active QQ Skin session is recorded." >&2; exit 1; }

PORT="$(sed -n 's/^port=//p' "$STATE_FILE")"
NODE="$(sed -n 's/^node=//p' "$STATE_FILE")"
case "$PORT" in ''|*[!0-9]*) echo "Saved skin port is invalid." >&2; exit 1 ;; esac
[ -x "$NODE" ] || { echo "Saved Codex runtime is unavailable." >&2; exit 1; }

"$NODE" "$ROOT/injector.js" --verify --port "$PORT" --timeout-ms "$TIMEOUT_MS"
echo "Codex QQ Skin verification passed."
