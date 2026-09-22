#!/usr/bin/env bash
set -uo pipefail

ok=0
bad=0

check() {
  local name="$1"
  shift
  if "$@" >/tmp/adw-doctor.out 2>/tmp/adw-doctor.err; then
    printf '[OK]   %s\n' "$name"
    ok=$((ok+1))
  else
    printf '[FAIL] %s\n' "$name"
    sed -n '1,3p' /tmp/adw-doctor.err | sed 's/^/       /'
    bad=$((bad+1))
  fi
}

check "tmux" tmux -V
check "uv" uv --version
check "Codex CLI" codex --version
check "Claude Code" claude --version
check "Composio CLI" composio --help
check "CAO" cao --help
check "profile: jev_supervisor" cao profile show jev_supervisor
check "profile: codex_developer" cao profile show codex_developer
check "profile: claude_reviewer" cao profile show claude_reviewer

printf '\nJev connectivity check (informational):\n'
if composio search "Jev Evaluate State" >/tmp/adw-jev.out 2>/tmp/adw-jev.err; then
  printf '[OK]   Composio can search for the Jev Evaluate State tool\n'
  sed -n '1,12p' /tmp/adw-jev.out | sed 's/^/       /'
else
  printf '[WARN] Jev search failed. If not linked, run: composio link jev\n'
  sed -n '1,5p' /tmp/adw-jev.err | sed 's/^/       /'
fi

printf '\nSummary: %s checks passed, %s failed.\n' "$ok" "$bad"

if [ "$bad" -gt 0 ]; then
  exit 1
fi
