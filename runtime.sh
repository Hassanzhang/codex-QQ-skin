#!/bin/bash
# Shared macOS runtime discovery for the launcher and diagnostics.

find_codex_app() {
  local candidate
  for candidate in "/Applications/Codex.app" "$HOME/Applications/Codex.app" "/Applications/ChatGPT.app" "$HOME/Applications/ChatGPT.app"; do
    [ -f "$candidate/Contents/Info.plist" ] || continue
    if /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$candidate/Contents/Info.plist" 2>/dev/null | grep -qx 'com.openai.codex'; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

resolve_codex_node() {
  local app node version major
  app="$(find_codex_app)" || return 1
  node="$app/Contents/Resources/cua_node/bin/node"
  [ -x "$node" ] || return 1
  version="$($node --version)" || return 1
  major="${version#v}"
  major="${major%%.*}"
  case "$major" in ''|*[!0-9]*) return 1 ;; esac
  [ "$major" -ge 20 ] || return 1
  printf '%s\n' "$node"
}

process_started_at() {
  LC_ALL=C /bin/ps -p "$1" -o lstart= 2>/dev/null | /usr/bin/awk '{$1=$1; print}'
}

recorded_watcher_matches() {
  local pid="$1" started="$2" node="$3" injector="$4" port="$5" command actual_started
  [ -n "$pid" ] && [ -n "$started" ] && [ -n "$node" ] && [ -n "$injector" ] && [ -n "$port" ] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  command="$(/bin/ps -p "$pid" -o command= 2>/dev/null || true)"
  actual_started="$(process_started_at "$pid")"
  [ "$actual_started" = "$started" ] || return 1
  case "$command" in
    "$node"*"$injector --watch --port $port"*) return 0 ;;
    *) return 1 ;;
  esac
}
