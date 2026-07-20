#!/bin/bash
# Check the local assets and, when active, verify the live renderer session.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
STATE_FILE="$HOME/Library/Application Support/CodexQQSkin/simple-state"
. "$ROOT/runtime.sh"

for file in injector.js renderer-template.js style.css theme.json assets/background.png assets/avatar.png assets/pet.png assets/frame.png; do
  [ -f "$ROOT/$file" ] || { echo "Missing required file: $file" >&2; exit 1; }
done
NODE="$(resolve_codex_node)" || { echo "Could not resolve Codex's bundled Node.js 20+ runtime." >&2; exit 1; }
"$NODE" "$ROOT/injector.js" --check-payload

if [ -f "$STATE_FILE" ]; then
  /bin/bash "$ROOT/verify.sh" --timeout-ms 12000
else
  echo "Payload is healthy. No active QQ Skin session is recorded."
fi
